class SKOS
  include LadderModel::Embedded
  bind_to RDF::SKOS, :type => Array, :only => [:prefLabel, :broader, :narrower]
  embedded_in :concept
end

class Concept
  include LadderModel::Core

  # embedded RDF vocabularies
  embeds_one :skos, class_name: "SKOS"

  @headings = [{:skos => :prefLabel},
               {:skos => :altLabel},
               {:skos => :hiddenLabel}]

  # model relations
  has_and_belongs_to_many :resources, index: true
  has_and_belongs_to_many :agents, index: true

  define_scopes
  define_indexes
end