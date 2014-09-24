require 'mongoid'
require 'active_triples'
require 'json/ld'

module Ladder::Resource
  extend ActiveSupport::Concern

  included do
    include Mongoid::Document
    include ActiveTriples::Identifiable
  end

  ##
  # Convenience method to return JSON-LD representation
  def as_jsonld
    update_resource { update_relations }
    resource.dump(:jsonld)
  end

  private
    ##
    # Updates ActiveTriples resource relation properties
    #
    # @see Mongoid::Relations
    def update_relations
      resource_class.properties.each do |name, prop|
        if relations.keys.include? name
          self.send(prop.term).to_a.each do |relation|
            relation.resource.set_value(relations[name].inverse, self.rdf_subject)
          end
        end
      end
    end

  public

    module ClassMethods
      ##
      # Default ActiveTriples #property integration
      #
      # @see Mongoid::Document
      def define(field_name, *args)

        if class_name = args.first[:class_name]
          has_and_belongs_to_many field_name, autosave: true, class_name: class_name
        else
          field field_name
        end

        property(field_name, *args)
      end
    end

end