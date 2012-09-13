class FOAF
  include LadderModel::Embedded
  bind_to RDF::FOAF, :type => Array
  embedded_in :agent
end

class Agent
  include LadderModel::Core

  def heading
    fields = ['foaf.name',
              'foaf.givenName',
              'foaf.givenname']
    self.get_first_field(fields)
  end

  # embedded RDF vocabularies
  embeds_one :foaf, class_name: "FOAF"

  # index embedded documents
  mapping indexes :foaf, :type => 'object'

  # model relations
  has_and_belongs_to_many :resources
end