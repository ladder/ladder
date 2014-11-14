module Ladder::Resource::Dynamic
  extend ActiveSupport::Concern

  included do
    include Ladder::Resource

    field :_context, type: Hash

    after_find :apply_context
    
    ##
    # Overload ActiveTriples #resource_class
    #
    # @see ActiveTriples::Identifiable
    private def resource_class
      @modified_resource_class ||= self.class.resource_class.clone
    end
    
    ##
    # Overload Ladder #update_resource
    #
    # @see Ladder::Resource
    def update_resource(opts = {})
      # FIXME: for some reason super has to go first or AT clobbers properties
      super(opts)

      if self._context
        self._context.each do |field_name, uri|
          resource.set_value(RDF::Vocabulary.find_term(uri), self.send(field_name))
        end
      end

      resource
    end

  end

  ##
  # Dynamic field definition
  def property(field_name, *opts)
    # Store context information
    self._context ||= Hash.new(nil)
    self._context[field_name] = opts.first[:predicate].to_s

    apply_context
  end

  private

    ##
    # Dynamic field accessors (Mongoid)
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

          # Update resource properties
          resource_class.property(field_name, predicate: term)
        end
      end
    end

end
