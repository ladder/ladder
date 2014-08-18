class MappingObject
  include Ladder::Resource # TODO: this looks like a Duck

  field :_model, type: String  # The name of a defined Ladder::Resource
  field :_types, type: Array   # (optional) a list of additional pname RDF classes to assign
  # NB: this uses dynamic fields for model vocabs
  # TODO: add validation here based on the model being mapped

  validates_presence_of :_model

  embedded_in :mapping
end

class Mapping
  include Mongoid::Document

  field :content_type, type: String  # A registered MIME-type for this mapping

  validates_presence_of :content_type

  embeds_many :mapping_objects, store_as: 'objects'

  # FIXME: TEMPORARY
  # test_mapping = Mapping.new_from_hash Tenant.new.properties[:mappings].first
  # test_mapping = Mapping.new_from_rdf content_type: 'application/mods+xml', graph: Mapping.test
  def self.test
    hash = JSON.parse File.read('lib/ladder/mapping.jsonld')
    graph = RDF::Graph.new << JSON::LD::API.toRdf(hash)
  end
  
  # Serialize a Mapping instance as a Hash using the following syntax:
  #
  # content_type: 'application/something',
  # objects: {
  #   id1: {
  #     _model: 'Model_A',
  #     _types: ['vocab:Class_A', 'vocab:Class_B'],
  #     vocab: {
  #       predicate_a: ['xpath', :id2],
  #     }
  #   },
  #   id2: {
  #     _model: 'Model_B',
  #     vocab: {
  #       predicate_b: ['xpath', :id1],
  #     }
  #   }
  # }
  
  def to_hash
    # Replace id references with object IDs
    mapping_objects = objects.map do |object|

      # Only descend into dynamic fields (vocabs)
      object.attributes.except(*object.fields.keys).each do |prefix, fields|
        fields.each do |field, value|
          # Ensure everything is an array so we can traverse it
          value = Array value

          value.each do |element|
            if element.is_a? Moped::BSON::ObjectId
              # Replace the Moped::BSON::ObjectId with a symbolic id reference
              value[value.index(element)] = "_#{element}".to_sym
              object.send(prefix)[field] = value
            end
          end

        end
      end
      
      { "_#{object.id}".to_sym => object.as_document.except('_id').symbolize_keys }
    end

    { content_type: content_type, objects: mapping_objects }
  end

  # Create a new Mapping instance from a Hash using the above syntax
  def self.new_from_hash(hash)
    mapping_objects = hash[:objects].map { |id, mapping| MappingObject.new mapping }
    
    # Create lookup table to resolve id references to object IDs
    table = Hash[hash[:objects].keys.zip mapping_objects.map(&:id)]
    
    # Replace id references with object IDs
    hash[:objects] = mapping_objects.map do |object|

      # Only descend into dynamic fields (vocabs)
      object.attributes.except(*object.fields.keys).each do |prefix, fields|
        fields.each do |field, value|
          # Ensure everything is an array so we can traverse it
          value = Array value

          value.each do |element|
            # ID references are symbols

            if element.is_a? Symbol and table.include? element
              # Replace the id reference with a Moped::BSON::ObjectId
              value[value.index(element)] = table[element]
              object.send(prefix)[field] = value
            end
          end
        end
      end

      object
    end

    self.new hash
  end

  # Take an RDF::Graph and create a Mapping instance from it
  #
  # Required parameters:
  # :content_type (String) -> the name of a MIME-type to register against
  # :graph (RDF::Graph)    -> a parsed RDF graph of the mapping (eg. from JSON-LD)

  def self.new_from_rdf(*args)
    opts = args.last || {}

    return unless content_type = opts[:content_type] and graph = opts[:graph]
    return unless content_type.is_a? String
    return unless graph.is_a? RDF::Graph and graph.valid?

    mapping_objects = Hash.new

    graph.to_hash.each do |object_node, predicates|
      object_hash = Hash.new

      predicates.each do |subject, object|
        # Special handling for :_model, :_types values
        if "rdf:type" == subject.pname

          object.each do |type|
            next if type.pname == type.to_s # if it can't resolve a pname, we don't know this vocab
            
            if :ladder == type.qname.first
              object_hash[:_model] = type.qname.last.to_s
            else
              object_hash[:_types] = Array.new if object_hash[:_types].nil?
              object_hash[:_types] << type.pname
            end

          end

          next
        end
        
        # NB: object will be 1- or 2- element array
        case object.count

        when 2
          if object.first.is_a? RDF::Literal
            value = object.first.to_s # XPath
            target = object.last.to_sym # id reference
          else
            value = object.last.to_s # NB: Ladder Class
            target = object.first.pname == object.first.to_s ? nil : object.first.pname
          end

        when 1
          if object.first.is_a? RDF::Literal
            value = object.first.to_s # XPath
          elsif object.first.is_a? RDF::Node
            target = object.first.to_sym # id reference
          end

        end

        qname = RDF::URI(subject).qname

        next if qname.nil? # if qname is nil, we don't know this subject

        object_hash[qname.first] = Hash.new if object_hash[qname.first].nil?
        object_hash[qname.first][qname.last] = [value, target].compact
      end
      
      mapping_objects[object_node.id.to_sym] = object_hash
    end

    new_from_hash content_type: content_type, objects: mapping_objects
  end

end