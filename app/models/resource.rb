class DC
  include Model::Embedded
  bind_to RDF::DC, :type => Array, :only => [:title, :alternative, :issued, :format,
                                             :extent, :language, :identifier, :abstract,
                                             :tableOfContents, :creator, :contributor,
                                             :publisher, :spatial, :subject, :isPartOf,
                                             :hasPart, :hasVersion, :isVersionOf, :hasFormat,
                                             :isFormatOf, :isReferencedBy, :references]

  bind_to Vocab::DC, :type => Array, :only => [:DDC, :LCSH, :LCC, :RVM]
  attr_accessible :identifier
  embedded_in :resource
end

class Bibo
  include Model::Embedded
  bind_to Vocab::Bibo, :type => Array, :only => [:isbn, :issn, :lccn, :oclcnum, :upc, :doi, :uri]
  embedded_in :resource
end

class Prism
  include Model::Embedded
  bind_to Vocab::Prism, :type => Array, :only => [:edition, :hasPreviousVersion, :issueIdentifier]
  embedded_in :resource
end

class DBpedia
  include Model::Embedded
  bind_to Vocab::DBpedia, :type => Array
  embedded_in :resource
end

class Resource
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :dcterms,  class_name: "DC"
  embeds_one :bibo,     class_name: "Bibo"
  embeds_one :prism,    class_name: "Prism"
  embeds_one :dbpedia,  class_name: "DBpedia"

  @rdf_types = {'Vocab::DBpedia'  => ['Work'],
                'Vocab::Schema'   => ['CreativeWork'],
                'RDF::DC'         => ['BibliographicResource'],
                'Vocab::Bibo'     => ['Document']}

  @headings = [{:dcterms => :title}, {:dcterms => :alternative}]

  # imported data objects
  field :marc, type: Model::CompressedBinary
  field :mods, type: Model::CompressedBinary

  # scopes
  scope :marc, ->(exists=true) { where(:marc.exists => exists) }
  scope :mods, ->(exists=true) { where(:mods.exists => exists) }

  # model relations
  has_and_belongs_to_many :agents, index: true
  has_and_belongs_to_many :concepts, index: true

  define_scopes
  define_indexes
end