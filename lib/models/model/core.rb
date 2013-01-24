#
# Common methods for all model classes within the application
#

class DBpedia
  include Model::Embedded
  bind_to Vocab::DBpedia, :type => Array
  embedded_in :resource
end

Fabricator(:DBpedia)

class RDFS
  include Model::Embedded
  bind_to RDF::RDFS, :type => Array
  embedded_in :resource
end

Fabricator(:RDFS)

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

    module ClassMethods

      # Override Mongoid #find_or_create_by
      # @see: http://rdoc.info/github/mongoid/mongoid/Mongoid/Finders
      def find_or_create_by(attrs = {}, &block)

        # use md5 fingerprint to query if a document already exists
        hash = self.normalize(attrs, {:ids => :omit})
        query = self.where(:md5 => Moped::BSON::Binary.new(:md5, Digest::MD5.digest(hash.to_s)))

        result = query.first
        return result unless result.nil?

        # otherwise create and return a new object
        obj = self.new(attrs)
        obj.save
        obj
      end

      def define_scopes
        # TODO: refactor to use self.vocabs
        embeddeds = self.reflect_on_all_associations(*[:embeds_one])

        embeddeds.each do |embed|
          scope embed.name, ->(exists=true) { where(embed.name.exists => exists) }
        end

        # add scope to check for documents not in ES index
        scope :unindexed, -> do

          # get the most recent timestamp
          s = self.search {
            query { all }
            sort { by :_timestamp, 'desc' }
            size 1
          }

          # if there's a timestamp in the index, use that as the offset
          unless s.results.empty?
            timestamp = s.results.first.sort.first / 1000
            self.queryable.or(:updated_at.gte => timestamp, :created_at.gte => timestamp)
          else
            self.queryable
          end
        end
      end

      def define_indexes
        # dynamic templates to store un-analyzed values for faceting
        # TODO: remove dynamic templates and use explicit mapping
        mapping :_source => { :compress => true },
                :_timestamp => { :enabled => true },
                :dynamic_templates => [{
                    :auto_facet => {
                        :match => '*',
                        :match_mapping_type => '*',
                        :mapping => {
                            :type => 'multi_field',
                            :fields => {
                                '{name}' => {
                                    :type => 'string',
                                    :index => 'analyzed'
                                },
                                :raw => {
                                    :type => 'string',
                                    :index => 'not_analyzed'
                                }
                            }
                        }
                    }
                 }] do

          embeddeds = self.reflect_on_all_associations(*[:embeds_one])
=begin
          # combine headings so we can operate on the them per-vocab
          combined = headings.inject do |a, b|
            a.merge(b) { |k, v1, v2| v1 == v2 ? v1 : [v1, v2].flatten }
          end
=end
          # map each embedded object
          embeddeds.each do |embed|
=begin
            # if this vocab contained headings, map them
            if combined[embed.name.to_sym]
              properties = {}

              # each vocab may have multiple heading fields
              fields = combined[embed.name.to_sym].to_a rescue [combined[embed.name.to_sym]]
              fields.each do |field|
                properties[field] = {:type => :string, :boost => 2}
              end

              indexes embed.name, :type => 'object', :properties => properties
            else
=end
              indexes embed.name, :type => 'object'
#            end
          end

          # Heading is what users will correlate with most
          indexes :heading,       :type => 'string', :boost => 2

          # RDF class information
          indexes :rdf_types,     :type => 'multi_field', :fields => {
                                  'rdf_types' => { :type => 'string', :index => 'analyzed' },
                                  :raw        => { :type => 'string', :index => 'not_analyzed' }
          }

          # Timestamp information
          indexes :created_at,    :type => 'date'
          indexes :deleted_at,    :type => 'date'
          indexes :updated_at,    :type => 'date'

          # Hierarchy information
          indexes :parent_id,     :type => 'string'
          indexes :parent_ids,    :type => 'string'

          # Relation information
          indexes :group_ids,     :type => 'string'
          indexes :agent_ids,     :type => 'string'
          indexes :concept_ids,   :type => 'string'
          indexes :resource_ids,  :type => 'string'
        end
      end

      def normalize(hash, opts={})
        # Use a sorted deep clone of the hash
        hash = Marshal.load(Marshal.dump(hash)).sort_by_key(true)

        # store relation ids if we need to resolve them
        if :resolve == opts[:ids]
          hash.symbolize_keys!

          opts[:type] = hash[:type] || self.name.underscore
          opts[:resource_ids] = hash[:resource_ids]
          opts[:agent_ids] = hash[:agent_ids]
          opts[:concept_ids] = hash[:concept_ids]
        end

        # Reject keys not declared in mapping
        hash.reject! { |key, value| ! self.tire.mapping.keys.include? key.to_sym } unless 'Group' == self.name

        # Self-contained recursive lambda
        normal = lambda do |hash, opts|

          hash.symbolize_keys!

          # Strip id field
          hash.except! :_id
          hash.except! :rdf_types

          # Modify Object ID references if specified
          if hash.class == Hash and opts[:ids]

            hash.each do |key, values|
              values.to_a.each do |value|

                # NB: have to use regexp matching for Tire Items
                if value.is_a? BSON::ObjectId or value.to_s.match(/^[0-9a-f]{24}$/)

                  case opts[:ids]
                    when :omit then
                      #hash[key].delete value     # doesn't work as expected?
                      hash[key][values.index(value)] = nil

                    when :resolve then
                      model = :resource if opts[:resource_ids].include? value rescue nil
                      model = :agent if opts[:agent_ids].include? value rescue nil
                      model = :concept if opts[:concept_ids].include? value rescue nil
                      model = opts[:type].to_sym if model.nil?

                      hash[key][values.index(value)] = {model => value.to_s}
                  end
                end
              end

              # remove keys that are now empty
              hash[key].to_a.compact!
            end

          end

          # Reject empty values
          hash.reject! { |key, value| value.kind_of? Enumerable and value.empty? }

          # Recurse into Hash values
          hash.values.select { |value| value.is_a? Hash }.each{ |h| normal.call(h, opts) }

          hash
        end

        normal.call(hash.reject { |key, value| !value.is_a? Hash }, opts)
      end

      def chunkify(opts = {})
        Mongoid::Criteria.new(self).chunkify(opts)
      end

      def vocabs
        embeddeds = reflect_on_all_associations(*[:embeds_one])

        vocabs = {}
        embeddeds.each do |embedded|
          vocabs[embedded.key.to_sym] = embedded.class_name.constantize
        end

        vocabs
      end

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

    def heading
      self.class.headings.each do |mapping|
        vocab = mapping.keys.first
        field = mapping.values.first

        target = self.send(vocab).send(field) unless self.send(vocab).nil?

        return target if target
      end

      [I18n.t('model.untitled')]
    end

    # more precise serialization for Tire
    def to_indexed_json
      mapping = self.class.tire.mapping

      # Reject keys not declared in mapping
      hash = self.as_document.reject { |key, value| ! mapping.keys.include? key.to_sym }

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