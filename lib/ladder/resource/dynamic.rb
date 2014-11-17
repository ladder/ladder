module Ladder::Resource::Dynamic
  extend ActiveSupport::Concern

  included do
    include Ladder::Resource

    field :_context, type: Hash

    after_find :apply_context
    
    ##
    # Overload Ladder #update_resource
    #
    # @see Ladder::Resource
    def update_resource(opts = {})
      # FIXME: for some reason super has to go first or AT clobbers properties
      super(opts)

      if self._context
        self._context.each do |field_name, uri|
          value = self.send(field_name)
          cast_uri = RDF::URI.new(value)
          resource.set_value(RDF::Vocabulary.find_term(uri), cast_uri.valid? ? cast_uri : value)
        end
      end

      resource
    end
    
    def <<(data)
      # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
      data = RDF::Statement.from(data) unless data.is_a? RDF::Statement

      # Define predicate on object unless it's defined on the class
      if resource_class.properties.values.map(&:predicate).include? data.predicate
        field_name = resource_class.properties.select { |name, term| term.predicate == data.predicate }.keys.first.to_sym
      else
        qname = data.predicate.qname

        if respond_to? qname.last or :name == qname.last
          field_name = qname.join('_').to_sym
        else
          field_name = qname.last
        end

        property field_name, predicate: data.predicate
      end

      # Set the value in Mongoid
      value = case data.object
        when RDF::Literal
          data.object.object
        when RDF::URI
          data.object.to_s
        else
          data.object
      end

      self.send("#{field_name}=", value)
    end

    private
    
      ##
      # Overload ActiveTriples #resource_class
      #
      # @see ActiveTriples::Identifiable
      def resource_class
        @modified_resource_class ||= self.class.resource_class.clone
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
