module LadderModel
  module Core
    def self.included(base)
      base.send :include, Mongoid::Document

      # useful extras, see: http://mongoid.org/en/mongoid/docs/extras.html
      base.send :include, Mongoid::Paranoia # soft deletes
      base.send :include, Mongoid::Timestamps
      base.send :include, Mongoid::Hierarchy
#      base.send :include, Mongoid::Versioning

      # ElasticSearch integration
      base.send :include, Tire::Model::Search
      base.send :include, Tire::Model::Callbacks
=begin
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
        }] do

        base.send :indexes, :created_at,  :type => 'date'
        base.send :indexes, :deleted_at,  :type => 'date'
        base.send :indexes, :updated_at,  :type => 'date'
      end
=end
    end

    # TODO: implement recursive null removal
#    def to_indexed_json
#
#    end
  end

  module Embedded
    def self.included(base)
      base.send :include, Mongoid::Document
      base.send :include, Mongoid::Versioning
      base.send :include, Easel::Bindable
    end
  end
end