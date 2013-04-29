class Concept
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :mads, class_name: 'MADS', cascade_callbacks: true, autobuild: true
  embeds_one :skos, class_name: 'SKOS', cascade_callbacks: true, autobuild: true

  @rdf_types = {:dbpedia => [:TopicalConcept],
                :rdafrbr => [:Concept],
                   :mads => [:Authority],
                   :skos => [:Concept]}

  @headings = [{:skos => :prefLabel},
               {:skos => :altLabel},
               {:skos => :hiddenLabel}]

  # imported data objects
  has_many :files, class_name: 'Mongoid::GridFS::Fs::File'

  # model relations
  has_and_belongs_to_many :groups, index: true
  has_and_belongs_to_many :resources, index: true
  has_and_belongs_to_many :agents, index: true

  # Enable history tracking for embedded documents
  track_history :on => vocabs.keys + [:md5]

  define_scopes
end