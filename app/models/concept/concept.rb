class SKOS
  include LadderModel::Embedded
  bind_to RDF::SKOS, :type => Array
  embedded_in :concept
end

class Concept
  include LadderModel::Core

  # embedded RDF vocabularies
  embeds_one :skos, class_name: "SKOS"

  # index embedded documents
  mapping indexes :skos, :type => 'object'

  # model relations
  has_and_belongs_to_many :resources
end