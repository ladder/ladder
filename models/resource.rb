class DublinCore
  include LadderModel::Embedded
  bind_to RDF::DC, :type => Array
  bind_to LadderVocab::DCVocab, :type => Array
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
  embeds_one :prism,   class_name: "Prism"

  # model relations
  has_and_belongs_to_many :agents
  has_and_belongs_to_many :concepts

  # TODO: move this into LadderModel::Core
  mapping :dynamic_templates => [{
    :test => {
        :match => '*',
        :mapping => {
            :type => 'multi_field',
            :fields => {
                '{name}' => {
                    :type => '{dynamic_type}',
                    :index => 'analyzed'
                },
                :raw => {
                    :type => '{dynamic_type}',
                    :index => 'not_analyzed'
                }
            }
        }
    }
  }] do
    indexes :created_at,  :type => 'date'
    indexes :updated_at,  :type => 'date'
    indexes :deleted_at,  :type => 'date'
    # END OF STUFF TO MOVE

    indexes :bibo,        :type => 'object'
    indexes :prism,       :type => 'object'
    indexes :dcterms,     :type => 'object'
  end
end