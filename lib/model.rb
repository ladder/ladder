#
# Common methods for all model classes within the application
#

module LadderModel

  module Core

    module ClassMethods

      # Override Mongoid #find_or_create_by
      # @see: http://rdoc.info/github/mongoid/mongoid/Mongoid/Finders

      def find_or_create_by(attrs = {}, &block)

        # build a query based on nested fields
        query = self
        attrs.each do |vocab, vals|
          vals.each do |field, value|
            query = query.all_of("#{vocab}.#{field}" => value) unless value.empty?
          end
        end

        # if a document exists, return that
        return query.first unless query.empty?

        # otherwise create and return a new object
        obj = self.new(attrs)
        obj.save
        obj
      end

      def normalize(hash)
        # use a deep clone of the hash
        hash = Marshal.load(Marshal.dump(hash))

        # Reject keys not declared in mapping
        hash.reject! { |key, value| ! self.tire.mapping.keys.map(&:to_s).include?(key.to_s) }

        # Self-contained recursive lambda
        normal = lambda do |hash|
          hash.symbolize_keys!

          # Strip id field
          hash.except! :_id

          # Reject empty values
          hash.reject! { |key, value| value.kind_of? Enumerable and value.empty? }
          hash.values.select { |value| value.is_a? Hash }.each{ |h| normal.call(h) }
          hash
        end

        normal.call(hash.reject { |key, value| !value.is_a? Hash })
      end

    end

    def self.included(base)
      base.send :include, Mongoid::Document

      # useful extras, see: http://mongoid.org/en/mongoid/docs/extras.html
      base.send :include, Mongoid::Paranoia # soft deletes
      base.send :include, Mongoid::Timestamps
      base.send :include, Mongoid::Tree
#      base.send :include, Mongoid::Tree::Ordering

      # ElasticSearch integration
      base.send :include, Tire::Model::Search
      base.send :include, Tire::Model::Callbacks

      # Pagination
      base.send :include, Kaminari::MongoidExtension::Criteria
      base.send :include, Kaminari::MongoidExtension::Document

      # dynamic templates to store un-analyzed values for faceting
      base.send :mapping, :dynamic_templates => [{
          :test => {
              :match => '*',
              :match_mapping_type => 'string',
              :mapping => {
                  :type => 'multi_field',
                  :fields => {
                      '{name}' => {
                          :type => '{dynamic_type}',
                          :index => 'analyzed'
                      },
                      :raw => {
                          :type => '{dynamic_type}',
                          :index => 'not_analyzed'
                      }
                  }
              }
          }
        }], :_source => { :compress => true } do

        # Timestamp information
        base.send :indexes, :created_at,    :type => 'date'
        base.send :indexes, :deleted_at,    :type => 'date'
        base.send :indexes, :updated_at,    :type => 'date'

        # Hierarchy information
        base.send :indexes, :parent_id,     :type => 'string'
        base.send :indexes, :parent_ids,    :type => 'string'

        # Relation information
        base.send :indexes, :agent_ids,     :type => 'string'
        base.send :indexes, :concept_ids,   :type => 'string'
        base.send :indexes, :resource_ids,  :type => 'string'

        # add useful class methods
        base.extend ClassMethods
      end

    end

    # Retrieve a hash of field names and embedded vocab objects
    def vocabs
      embeddeds = self.reflect_on_all_associations(*[:embeds_one])

      vocabs = {}
      embeddeds.each do |embedded|
        vocab = self.method(embedded.key).call
        vocabs[embedded.key.to_sym] = vocab unless vocab.nil?
      end

      vocabs
    end

    # Assign model vocab objects by a hash of field names
    def vocabs=(hash)
      hash.each do |field, object|
        self.send(field.to_s + '=', object) if self.respond_to? field
      end
    end

    # Search the index and return a Tire::Collection of documents that have a similarity score
    def similar(query=false)
      return @similar unless query || @similar.nil?

      hash = self.class.normalize(self.as_document)
      id = self.id

      results = self.class.tire.search do
        query do
          boolean do
            # do not include self
            must_not { term :_id, id }

            hash.each do |vocab, vals|
              vals.each do |field, value|

                query_string = value.join(' ').gsub(/[-+!\(\)\{\}\[\]^"~*?:;,.\\]|&&|\|\|/, '')
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

      p1 = self.class.normalize(self.as_document).values.map(&:values).flatten.map(&:to_s).sort.join(' ').gsub(/[-+!\(\)\{\}\[\]\n^"~*?:;,.\\]|&&|\|\|/, '')
      p2 = self.class.normalize(compare).values.map(&:values).flatten.map(&:to_s).sort.join(' ').gsub(/[-+!\(\)\{\}\[\]\n^"~*?:;,.\\]|&&|\|\|/, '')

      # Reject Object ID references in comparisons
      # NB: have to use regexp matching for Tire Items
      #
      # hash.reject! {|key, value| value.is_a? BSON::ObjectId || value.to_s.match(/^[0-9a-f]{24}$/) }
      # hash.reject! {|key, value| value.is_a? Array and value.flatten.reject { |x| x.is_a?(BSON::ObjectId) || x.to_s.match(/^[0-9a-f]{24}$/) }.empty?}

      options.each do |sim, bool|
        options[sim] = p1.send(sim, p2) if bool
      end

      options
    end

    # Search an array of model fields in order and return the first non-empty value
    def get_first_field(fields_array)
      target = nil

      fields_array.each do |target_field|
        ns = target_field.split('.').first
        field = target_field.split('.').last

        target = self.send(ns).send(field)

        break if target
      end

      target
    end

    # more precise serialization for Tire
    def to_indexed_json
      mapping = self.class.tire.mapping

      # Reject keys not declared in mapping
      hash = self.as_document.reject { |key, value| ! mapping.keys.map(&:to_s).include?(key.to_s) }

      # Reject empty values
      hash = hash.reject { |key, value| value.kind_of? Enumerable and value.empty? }

      # add heading
      hash[:heading] = self.heading

      hash.to_json
    end

  end

  module Embedded

    def self.included(base)
      base.send :include, Mongoid::Document
      base.send :include, Easel::Bindable
    end

  end

end

#
# compress/encode imported data to save space/memory in Mongo
#

class CompressedBinary
  include Mongoid::Fields::Serializable

  def serialize(string)
    # compress string for storage
    string ? Base64.encode64(ActiveSupport::Gzip.compress(string)) : string
  end

  def deserialize(compressed)
    # decompress string
    compressed ? ActiveSupport::Gzip.decompress(Base64.decode64(compressed)) : compressed
  end

end