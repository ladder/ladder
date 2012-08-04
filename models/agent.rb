class FOAF
  include LadderModel::Embedded
  bind_to RDF::FOAF
  embedded_in :agent
end

class Agent
  include LadderModel::Core

  # embedded RDF vocabularies
  embeds_one :foaf, class_name: "FOAF"

  # index embedded documents
  mapping indexes :foaf, :type => 'object'

  # model relations
  has_and_belongs_to_many :resources
end