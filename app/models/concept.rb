class SKOS
  include LadderModel::Embedded
  bind_to RDF::SKOS, :type => Array, :only => [:prefLabel, :broader, :narrower]
  embedded_in :concept
end

class Concept
  include LadderModel::Core

  def heading
    get_first_field(['skos.prefLabel', 'skos.altLabel', 'skos.hiddenLabel']) || ['untitled']
  end

  # embedded RDF vocabularies
  embeds_one :skos, class_name: "SKOS"

  # scopes
  define_scopes

  # mongoid indexing
  define_indexes

  # model relations
  has_and_belongs_to_many :resources, index: true
  has_and_belongs_to_many :agents, index: true
end