class SKOS
  include Model::Embedded
  bind_to RDF::SKOS, :type => Array, :only => [:prefLabel, :altLabel, :hiddenLabel, :broader, :narrower]
  embedded_in :concept
end


class Concept
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :skos, class_name: 'SKOS'

  @rdf_types = [[:dbpedia, :TopicalConcept],
                [:skos, :Concept]]

  @headings = [{:skos => :prefLabel},
               {:skos => :altLabel},
               {:skos => :hiddenLabel}]

  # model relations
  has_and_belongs_to_many :resources, index: true
  has_and_belongs_to_many :agents, index: true

  define_scopes
  define_indexes
end