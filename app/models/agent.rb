class FOAF
  include LadderModel::Embedded
  bind_to RDF::FOAF, :type => Array, :only => [:name, :birthday, :title]
  embedded_in :agent
end

class VCard
  include LadderModel::Embedded
  bind_to LadderVocab::VCard, :type => Array, :only => []

  self.fields.map(&:first).map(&:to_sym).each do |field|
    if field_alias = LadderVocab::VCard.aliases[field]
      alias_method field_alias, field
    end
  end

  embedded_in :agent
end

class Agent
  include LadderModel::Core

  def heading
    get_first_field(['foaf.name']) || ['untitled']
  end

  # embedded RDF vocabularies
  embeds_one :foaf, class_name: "FOAF"
  embeds_one :vcard, class_name: "VCard"

  # scopes
  define_scopes

  # mongoid indexing
  define_indexes

  # model relations
  has_and_belongs_to_many :resources, index: true
  has_and_belongs_to_many :concepts, index: true
end