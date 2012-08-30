module LadderModel
  module Core
    def self.included(base)
      base.send :include, Mongoid::Document

      # useful extras, see: http://mongoid.org/en/mongoid/docs/extras.html
      base.send :include, Mongoid::Paranoia # soft deletes
      base.send :include, Mongoid::Timestamps
      base.send :include, Mongoid::Tree

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
        base.send :indexes, :created_at,  :type => 'date'
        base.send :indexes, :deleted_at,  :type => 'date'
        base.send :indexes, :updated_at,  :type => 'date'

        # Relation information
        base.send :indexes, :parent_id,   :type => 'string'
        base.send :indexes, :parent_ids,  :type => 'string'
        base.send :indexes, :agent_ids,   :type => 'string'
        base.send :indexes, :concept_ids, :type => 'string'
      end

      def to_indexed_json
        mapping = self.class.tire.mapping

        # Reject keys not declared in mapping
        hash = self.attributes.reject { |key, value| ! mapping.keys.map(&:to_s).include?(key.to_s) }

        # Reject empty values
        hash = hash.reject { |key, value| value.kind_of? Enumerable and value.empty? }

        hash.to_json
      end

      def vocabs
        embeddeds = self.reflect_on_all_associations(*[:embeds_one])

        vocabs = []
        embeddeds.each do |embedded|
          vocab = self.method(embedded.key).call
          vocabs << vocab unless vocab.nil?
        end

        vocabs
      end

      def find_similar
        hash = self.dup.as_document.delete_if { |k,v| !v.is_a?(Hash) }
        id = self.id

        results = Resource.tire.search do
          query do
            boolean do
              hash.each do |vocab, vals|
                vals.each do |field, value|
                  next if value.is_a?(BSON::ObjectId)
#                  next if value.flatten.delete_if { |x| x.is_a?(BSON::ObjectId) }.empty?

                  fieldname = "#{vocab}.#{field}"
                  query_string = value.join(' ').gsub(/[-+!\(\)\{\}\[\]^"~*?:;,.\\]|&&|\|\|/, '')

                  should do
                    text fieldname.to_sym, query_string
                  end
                  must_not do
                    term :_id, id
                  end

                end
              end
            end
          end
          min_score 1
        end

        results
      end

      def diff(resource)
        # strip id field and symbolize all keys
        normalize = lambda do |hash|
          hash.symbolize_keys!
          hash.except!(:_id)
          hash.values.select{|v| v.is_a? Hash}.each{|h| normalize.call(h)}
          hash
        end

        test1 = normalize.call(self.as_document.reject { |key, value| !value.is_a? Hash })
        test2 = normalize.call(resource.to_hash.reject { |key, value| !value.is_a? Hash })

        # return the diff comparison
        HashDiff.diff(test1, test2)
      end

    end
  end

  module Embedded
    def self.included(base)
      base.send :include, Mongoid::Document
      base.send :include, Easel::Bindable
    end
  end
end