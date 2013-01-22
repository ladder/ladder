class FOAF
  include Model::Embedded
  bind_to RDF::FOAF, :type => Array, :only => [:name, :birthday, :title]
  embedded_in :agent
end

class VCard
  include Model::Embedded
  bind_to Vocab::VCard, :type => Array, :only => []

  # enable camelCase field aliases
  Vocab::VCard.aliases.each do |name, new|
    alias_method new, name if fields.map(&:first).include? name.to_s
  end

  embedded_in :agent
end

class Agent
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :foaf,     class_name: 'FOAF'#,   autobuild: true
  embeds_one :vcard,    class_name: 'VCard'#,  autobuild: true

  @rdf_types = [[:dbpedia, :Agent],
                [:foaf, :Agent]]

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

  define_scopes
  define_indexes
end