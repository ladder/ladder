class FOAF
  include LadderModel::Embedded
  bind_to RDF::FOAF
  embedded_in :agent
end

class Agent
  include LadderModel::Core

  # embedded RDF vocabularies
  embeds_one :foaf, class_name: "FOAF"

  # model relations
  has_and_belongs_to_many :resources

  # index mapping
  mapping do
    indexes :created_at,  :type => 'date'
    indexes :deleted_at,  :type => 'date'
    indexes :updated_at,  :type => 'date'

    indexes :foaf,        :type => 'object'
  end
end