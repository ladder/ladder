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
  end

  ##
  # Dynamic field definition
  def property(field_name, *opts)
    # Store context information
    self._context ||= Hash.new(nil)

    # Ensure new field name is unique
    field_name = opts.first[:predicate].qname.join('_').to_sym if respond_to? field_name or :name == field_name
    self._context[field_name] = opts.first[:predicate].to_s

    apply_context
  end

  def <<(data)
    # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
    data = RDF::Statement.from(data) unless data.is_a? RDF::Statement

    # Define predicate on object unless it's defined on the class
    if resource_class.properties.values.map(&:predicate).include? data.predicate
      field_name = resource_class.properties.select { |name, term| term.predicate == data.predicate }.keys.first.to_sym
    else
      qname = data.predicate.qname
      field_name = (respond_to? qname.last or :name == qname.last) ? qname.join('_').to_sym : qname.last

      property field_name, predicate: data.predicate
    end

    # Set the value in Mongoid
    value = data.object.is_a?(RDF::Literal) ? data.object.object : data.object.to_s
    self.send("#{field_name}=", value)
  end

  private

    ##
    # Dynamic field accessors (Mongoid)
    def create_accessors(field_name)
      define_singleton_method(field_name) { read_attribute(field_name) }
      define_singleton_method("#{field_name}=") { |value| write_attribute(field_name, value) } 
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

  public
  
  module ClassMethods
    
    private
      ##
      # Overload ActiveTriples #resource_class
      #
      # @see ActiveTriples::Identifiable
      def resource_class
        @modified_resource_class ||= self.class.resource_class.clone
      end
  end

end