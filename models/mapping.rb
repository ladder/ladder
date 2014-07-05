class MappingObject
  include Ladder::Model

  field :_model, type: String  # The name of a defined Ladder::Model
  field :_types, type: Array   # (optional) a list of additional pname RDF classes to assign
  # NB: this uses dynamic fields for model vocabs
  # TODO: add validation here based on the model being mapped

  embedded_in :mapping
end

class Mapping
  include Mongoid::Document

  field :content_type, type: String  # A registered MIME-type for this mapping
  embeds_many :mapping_objects, store_as: 'objects'

  # FIXME: TEMPORARY
  # test_mapping = Mapping.new_from_hash Tenant.new.properties[:mappings].first

  # Create a new Mapping instance from an object-hash syntax, eg.
  #
  # id1: {
  #   _model: 'Model_A',
  #   _types: ['vocab:Class_A', 'vocab:Class_B'],
  #   vocab: {
  #     predicate_a: ['xpath', :id2],
  #   }
  # },
  # id2: {
  #   _model: 'Model_B',
  #   vocab: {
  #     predicate_b: ['xpath', :id1],
  #   }
  # }

  def self.new_from_hash(mapping_hash)
    mapped_objects = mapping_hash[:objects].map do |id, mapping|
      MappingObject.new mapping
    end
    
    # Create lookup table to resolve id references to object IDs
    table = Hash[mapping_hash[:objects].keys.zip mapped_objects.map(&:id)]
    
    # Replace id references with object IDs
    mapped_objects = mapped_objects.map do |object|

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

    mapping_hash[:objects] = mapped_objects

    self.new mapping_hash
  end

=begin
  def self.test
    hash = JSON.parse File.read('lib/ladder/mapping.jsonld')
    graph = ::RDF::Graph.new << JSON::LD::API.toRdf(hash)
  end

  # Take an RDF::Graph and create a Mapping instance from it
  def self.new_from_rdf(graph)
    return unless graph.valid?

    # consider iterating over graph.to_hash
    graph.to_hash.each do |object_node, predicates|
      p "OBJECT ID #{object_node}"

      predicates.each do |subject, object|
        # NB: object will be 1- or 2- element array
        case object.count

        when 2
          if object.first.is_a? RDF::Literal
            value = object.first
            target = object.last
          else
            value = object.last
            target = object.first
          end

        when 1
          if object.first.is_a? RDF::Literal
            value = object.first
          else
            target = object.first
          end
        end

        qname = RDF::URI(subject).qname

        next if qname.nil?# if qname is nil, we don't know this subject

        p "['#{qname.join(':')}', '#{value}', '#{target}'],"
      end
      
    end
    
    nil
  end
=end
end