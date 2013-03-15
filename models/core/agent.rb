class Agent
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :foaf,     class_name: 'FOAF',   cascade_callbacks: true, autobuild: true
  embeds_one :vcard,    class_name: 'VCard',  cascade_callbacks: true, autobuild: true

  @rdf_types = {:dbpedia => [:Agent],
                :rdafrbr => [:Agent],
                   :foaf => [:Agent]}

  @headings = [{:rdfs => :label},
               {:foaf => :name},
               {:foaf => :givenName},
               {:foaf => :surname}]

  # imported data objects
  has_many :files, class_name: 'Model::File'

  # model relations
  has_and_belongs_to_many :groups, index: true
  has_and_belongs_to_many :resources, index: true
  has_and_belongs_to_many :concepts, index: true

  # Enable history tracking for embedded documents
  track_history :on => vocabs.keys + [:md5]

  define_scopes
end