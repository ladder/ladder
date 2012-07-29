class SKOS
  include LadderModel::Embedded
  bind_to RDF::SKOS
  embedded_in :concept
end

class Concept
  include LadderModel::Core

  # embedded RDF vocabularies
  embeds_one :skos, class_name: "SKOS"

  # model relations
  has_and_belongs_to_many :resources

  # index mapping
  mapping do
    indexes :created_at,  :type => 'date'
    indexes :deleted_at,  :type => 'date'
    indexes :updated_at,  :type => 'date'

    indexes :skos,        :type => 'object'
  end
end