class DublinCore
  include LadderModel::Embedded
  bind_to RDF::DC, :type => Array, :only => [:title, :alternative, :issued, :format,
                                             :extent, :language, :identifier, :abstract,
                                             :tableOfContents, :creator, :contributor,
                                             :publisher, :subject, :isPartOf, :hasPart,
                                             :hasVersion, :isVersionOf, :hasFormat,
                                             :isFormatOf, :isReferencedBy, :references]

  bind_to LadderVocab::DCVocab, :type => Array, :only => [:DDC, :LCC]
  attr_accessible :identifier
  embedded_in :resource
end

class Bibo
  include LadderModel::Embedded
  bind_to LadderVocab::Bibo, :type => Array, :only => [:isbn, :issn, :lccn, :oclcnum, :upc, :doi, :uri]
  embedded_in :resource
end

class Prism
  include LadderModel::Embedded
  bind_to LadderVocab::Prism, :type => Array, :only => [:edition, :hasPreviousVersion, :issueIdentifier]
  embedded_in :resource
end

class Resource
  include LadderModel::Core

  # embedded RDF vocabularies
  embeds_one :dcterms, class_name: "DublinCore"
  embeds_one :bibo,    class_name: "Bibo"
  embeds_one :prism,   class_name: "Prism"

  @headings = [{:dcterms => :title},
               {:dcterms => :alternative}]

  # imported data objects
  field :marc, type: CompressedBinary
  field :mods, type: CompressedBinary

  # scopes
  scope :marc, ->(exists=true) { where(:marc.exists => exists) }
  scope :mods, ->(exists=true) { where(:mods.exists => exists) }

  # model relations
  has_and_belongs_to_many :agents, index: true
  has_and_belongs_to_many :concepts, index: true

  define_scopes
  define_indexes
end