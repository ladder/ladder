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

    def normalize(opts={})
      # get a hash that we can modify
      !! opts[:localize] ? hash = self.to_hash : hash = self.as_document

      self.class.normalize(Marshal.load(Marshal.dump(hash)), opts)
    end

    def generate_md5
      hash = self.normalize({:ids => :omit})

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
      update_attributes(hash)
    end

    def heading
      self.class.headings.each do |heading|
        vocab = heading.keys.first
        field = heading.values.first

        target = send(vocab).send(field) unless send(vocab).nil?

        return target if target
      end

      [I18n.t('model.untitled')]
    end

    def locales
      self.normalize.values.map {|vocab| vocab.map {|field, values| values.keys} }.flatten.uniq
    end

    # Return a HashDiff array computed between the two model instances
    def diff(model, opts={})

      p1 = self.normalize(opts.slice(:ids))
      p2 = model.normalize(opts.slice(:ids))

      # TODO: use to calculate a similarity score somehow
      p1_size = p1.values.map(&:values).flatten.map(&:values).flatten.map(&:to_s).size
      p2_size = p2.values.map(&:values).flatten.map(&:values).flatten.map(&:to_s).size

      HashDiff.diff(p1, p2)
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
      options = opts if opts.is_a? Hash and ! opts.empty?

      p1 = self.normalize(options.slice(:ids))
      p2 = model.normalize(options.slice(:ids))

      p1 = p1.values.map(&:values).flatten.map(&:values).flatten.map(&:to_s).join(' ').normalize
      p2 = p2.values.map(&:values).flatten.map(&:values).flatten.map(&:to_s).join(' ').normalize

      # calculate amatch score for each algorithm
      options.delete :ids
      options.each do |sim, bool|
        options[sim] = p1.send(sim, p2) if bool
      end

      options
    end

    # Search the index and return a Tire::Collection of documents that have a similarity score
    def similar(opts={})

      hash = self.normalize({:ids => :omit})
      id = self.id

      results = self.class.search do
        query do
          boolean do
            # do not include self
            must_not { term :_id, id.to_s }

            hash.each do |name, vocab|
              vocab.each do |field, locales|
                locales.each do |locale, values|
                  values.each do |value|
                    should do
                      match "#{name}.#{field}.#{locale}", \
                            value.normalize({:space_char => ' '}).truncate(100, :separator => ' ')
                    end
                  end
                end
              end
            end
          end
        end
        min_score 1
      end

      if opts[:amatch]
        # calculate amatch score for each result
        results.each do |result|
          match = self.amatch(result, opts[:amatch])
          result.diff = match.values.sum / match.size
        end
      end

      @similar = results
    end

    # more precise serialization for Tire
    def to_indexed_json
      # Use normalized copy of document
      hash = self.normalize(:all_keys => true)

      # add heading
      hash[:heading] = heading

      # add locales
      hash[:locales] = locales

      # store RDF type for faceting; property only, not qname
      hash[:rdf_types] = rdf_types.map(&:last).uniq unless rdf_types.nil?

      hash.to_json
    end

    def to_rdfxml(url)
      uri = URI.parse(url)

      # get the RDF graph for each vocab
      graphs = []
      self.vocabs.each do |name, object|
        graph = object.to_rdf(RDF::URI.intern(url))

        graph.statements.each do |statement|
          # resolve IDs
          value = statement.object.object

          # TODO: refactor as Model/Core/ClassMethods#normalize
          if value.is_a? BSON::ObjectId or value.to_s.match(/^[0-9a-f]{24}$/)
            if defined? resource_ids and resource_ids.include? value
              model = :resource
            elsif defined? agent_ids and agent_ids.include? value
              model = :agent
            elsif defined? concept_ids and concept_ids.include? value
              model = :concept
            else
              model = self.class.name.underscore
            end

            new_statement = [statement.subject, statement.predicate, RDF::URI.intern("#{uri.scheme}://#{uri.host}/#{model}/#{statement.object}")]
            graph.delete(statement)
            graph << new_statement
          end
        end

        graphs << graph
      end

      RDF::RDFXML::Writer.buffer do |writer|
        # FIXME: this is necessary to write a rdf:Description element
        writer << RDF::Statement.new(RDF::URI.intern(url), RDF.type, RDF::URI.intern(''))

        types = self.class.rdf_types + (rdf_types || [])

        types.each do |qname, property|
          writer << RDF::Statement.new(RDF::URI.intern(url), RDF.type, RDF::URI.from_qname(qname) / property)
        end

        graphs.each do |graph|
          writer << graph
        end
      end

    end

  end

end