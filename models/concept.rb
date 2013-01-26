class Concept
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :skos, class_name: 'SKOS'#, autobuild: true

  @rdf_types = [[:dbpedia, :TopicalConcept],
                [:skos, :Concept]]

  @headings = [{:skos => :prefLabel},
               {:skos => :altLabel},
               {:skos => :hiddenLabel}]

  # imported data objects
  has_many :files, class_name: 'Model::File'

  # model relations
  has_and_belongs_to_many :groups, index: true
  has_and_belongs_to_many :resources, index: true
  has_and_belongs_to_many :agents, index: true

  define_scopes
end