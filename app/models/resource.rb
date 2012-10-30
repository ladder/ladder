class DublinCore
  include LadderModel::Embedded
  bind_to RDF::DC, :type => Array
  bind_to LadderVocab::DCVocab, :type => Array
  attr_accessible :identifier
  embedded_in :resource
end

class Bibo
  include LadderModel::Embedded
  bind_to LadderVocab::Bibo, :type => Array
  embedded_in :resource
end

class Prism
  include LadderModel::Embedded
  bind_to LadderVocab::Prism, :type => Array
  embedded_in :resource
end

class Resource
  include LadderModel::Core

  # imported data objects
  field :marc, :type => CompressedBinary
  field :mods, :type => CompressedBinary

  # embedded RDF vocabularies
  embeds_one :dcterms, class_name: "DublinCore"
  embeds_one :bibo,    class_name: "Bibo"
#  embeds_one :prism,   class_name: "Prism"

  # scopes
  define_scopes
  scope :marc, ->(exists=true) { where(:marc.exists => exists) }
  scope :mods, ->(exists=true) { where(:mods.exists => exists) }

  # mongoid indexing
  define_indexes({:dcterms => [:title, :alternative, :issued, :format, :extent, :language, :identifier, :abstract, :tableOfContents, :publisher, :DDC, :LCC],
                  :bibo => [:isbn, :issn, :lccn, :oclcnum]})

  # model relations
  has_and_belongs_to_many :agents, index: true
  has_and_belongs_to_many :concepts, index: true

  def heading
    get_first_field(['dcterms.title', 'dcterms.alternative']) || ['untitled']
  end
end