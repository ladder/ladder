#require 'mongoid'
#require 'active_triples'

module Ladder::Resource::Dynamic
  extend ActiveSupport::Concern

  included do
    include Ladder::Resource

    field :_context, type: Hash

    after_find :apply_context
  end

  ##
  # Dynamic field definition
  def property(field_name, *opts)
    # Store context information
    self._context ||= Hash.new(nil)
    self._context[field_name] = opts.first[:predicate].to_s

    create_accessors field_name

    # Update resource properties
    resource_class.property(field_name, *opts)
  end

  private

    ##
    # Dynamic field accessors
    def create_accessors(field_name)
      define_singleton_method field_name do
        read_attribute(field_name)
      end

      define_singleton_method "#{field_name}=" do |value|
        write_attribute(field_name, value)
      end
    end
    
    ##
    # Apply dynamic fields and properties to this instance
    def apply_context
      return unless self._context

      self._context.each do |field_name, uri|
        next if fields.keys.include? field_name

        if term = RDF::Vocabulary.find_term(uri)
          create_accessors field_name
          
          resource_class.property(field_name, predicate: term)
        end
      end
    end

end