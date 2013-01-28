#
# Instance methods for all model classes within the application
#

module Model

  module Core

    def self.included(base)
      base.send :include, Mongoid::Document

      # useful extras, see: http://mongoid.org/en/mongoid/docs/extras.html
      base.send :include, Mongoid::Paranoia # soft deletes
      base.send :include, Mongoid::Timestamps
      base.send :include, Mongoid::Tree
      #base.send :include, Mongoid::Tree::Ordering

      # Pagination
      base.send :include, Kaminari::MongoidExtension::Criteria
      base.send :include, Kaminari::MongoidExtension::Document

      # ElasticSearch integration
      # don't index group since they are only a structural construct
      unless 'Group' == base.name
        base.send :include, Tire::Model::Search
        base.send :include, Tire::Model::Callbacks2 # local patched version
        base.send :index_name, base.database_name
      end

      # Generate MD5 fingerprint for this document
      base.send :field, :md5
      base.send :index, 'md5' => 1
      base.send :set_callback, :save, :before, :generate_md5

      # Make :headings a readable class variable
      base.send :class_eval, %(class << self; attr_reader :headings end)

      # Create rdf_types field and accessor
      base.send :class_eval, %(class << self; attr_reader :rdf_types end)
      base.send :field, :rdf_types

      # Include default embedded vocabularies
      base.send :embeds_one, :dbpedia,  class_name: 'DBpedia'#,  autobuild: true
      base.send :embeds_one, :rdfs,     class_name: 'RDFS'#,     autobuild: true

      # add useful class methods
      # NB: This has to be at the end to monkey-patch Tire, Kaminari, etc.
      base.extend ClassMethods
    end

    def generate_md5
      hash = self.class.normalize(self.as_document, {:ids => :omit})
      self.md5 = Moped::BSON::Binary.new(:md5, Digest::MD5.digest(hash.to_s))
    end

    # Retrieve a hash of field names and embedded vocab objects
    def vocabs
      vocabs = {}

      self.class.vocabs.keys.each do |vocab|
        value = self.method(vocab).call
        vocabs[vocab] = value unless value.nil?
      end

      vocabs
    end

    # Assign model vocab objects by a hash of field names
    def vocabs=(hash)
      self.update_attributes(hash)
    end

    def heading
      self.class.headings.each do |mapping|
        vocab = mapping.keys.first
        field = mapping.values.first

        target = self.send(vocab).send(field) unless self.send(vocab).nil?

        return target if target
      end

      [I18n.t('model.untitled')]
    end

    # Return a HashDiff array computed between the two model instances
    def diff(model)
      # use the right type for masqueraded search results
      if model.is_a? Tire::Results::Item
        compare = model.to_hash
      else
        compare = model.as_document
      end

      # return the diff comparison
      HashDiff.diff(self.class.normalize(self.as_document), self.class.normalize(compare))
    end

    def amatch(model, opts={})
      options = {:hamming_similar => true,
                 :jaro_similar => true,
                 :jarowinkler_similar => true,
                 :levenshtein_similar => true,
                 :longest_subsequence_similar => true,
                 :longest_substring_similar => true,
                 :pair_distance_similar => true}

      # if we have selected specific comparisons, use those
      options = opts unless opts.empty?

      # use the right type for masqueraded search results
      if model.is_a? Tire::Results::Item
        compare = model.to_hash
      else
        compare = model.as_document
      end

      p1 = self.class.normalize(self.as_document, options.slice(:ids))
      p2 = self.class.normalize(compare, options.slice(:ids))

      p1 = p1.values.map(&:values).flatten.map(&:to_s).join(' ').normalize
      p2 = p2.values.map(&:values).flatten.map(&:to_s).join(' ').normalize

      # calculate amatch score for each algorithm
      options.delete :ids
      options.each do |sim, bool|
        options[sim] = p1.send(sim, p2) if bool
      end

      options
    end

    # Search the index and return a Tire::Collection of documents that have a similarity score
    def similar(query=false)
      return @similar unless query or @similar.nil?

      hash = self.class.normalize(self.as_document)
      id = self.id

      results = self.class.tire.search do
        query do
          boolean do
            # do not include self
            must_not { term :_id, id.to_s }

            hash.each do |vocab, vals|
              vals.each do |field, value|

                # NB: this requires increasing index.query.bool.max_clause_count
                # TODO: perhaps search against _all?
                query_string = value.join(' ')#.normalize
                should { text "#{vocab}.#{field}", query_string }

              end
            end
          end
        end
        min_score 1
      end

      @similar = results
    end

    # more precise serialization for Tire
    def to_indexed_json
      # TODO: can retrieve this from define_mapping logic above, and save sending a query to ES
      mapping = tire.index.mapping[self.class.name.downcase]['properties']

      # Reject keys not declared in mapping
      hash = self.as_document.reject { |key, value| ! mapping.keys.include? key }

      # Reject empty values
      hash = hash.reject { |key, value| value.kind_of? Enumerable and value.empty? }

      # add heading
      hash[:heading] = self.heading

      # store RDF type for faceting; property only, not qname
      hash[:rdf_types] = self.rdf_types.map(&:last).uniq unless self.rdf_types.nil?

      hash.to_json
    end

    def to_rdfxml(url)
      uri = URI.parse(url)

      # normalize into a hash to resolve ID references
      normal = self.class.normalize(self.as_document, {:ids => :resolve})

      normal.each do |name, vocab|
        vocab.each do |field, values|
          values.each do |value|
            if value.is_a? Hash
              # replace ID references with URI references
              normal[name][field][values.index(value)] = RDF::URI.intern("#{uri.scheme}://#{uri.host}/#{value.keys.first}/#{value.values.first}")
            end
          end
        end
      end

      # create a new model object from the modified values
      new_obj = self.class.new(normal)

      RDF::RDFXML::Writer.buffer do |writer|
        # FIXME: this is necessary to write a rdf:Description element
        writer << RDF::Statement.new(RDF::URI.intern(url), RDF.type, RDF::URI.intern(''))

        types = self.class.rdf_types + (self.rdf_types || [])

        types.each do |qname, property|
          writer << RDF::Statement.new(RDF::URI.intern(url), RDF.type, RDF::URI.from_qname(qname) / property)
        end

        # get the RDF graph for each vocab
        new_obj.vocabs.each do |key, object|
          writer << object.to_rdf(RDF::URI.intern(url))
        end
      end

    end

  end

end