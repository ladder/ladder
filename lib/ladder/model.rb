module LadderModel
  module Core
    def self.included(base)
      base.send :include, Mongoid::Document

      # useful extras, see: http://mongoid.org/en/mongoid/docs/extras.html
      base.send :include, Mongoid::Paranoia # soft deletes
      base.send :include, Mongoid::Timestamps
      base.send :include, Mongoid::Tree
      base.send :include, Mongoid::Tree::Traversal

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
        hash = self.attributes.reject { |key, value| value.kind_of? Enumerable and value.empty? }

        hash.to_json
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