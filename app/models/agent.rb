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

class DBpedia
  include Model::Embedded
  bind_to Vocab::DBpedia, :type => Array
  embedded_in :resource
end

class RDFS
  include Model::Embedded
  bind_to RDF::RDFS, :type => Array
  embedded_in :resource
end

class Agent
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :foaf,     class_name: "FOAF"
  embeds_one :vcard,    class_name: "VCard"

  # TODO: embed on all models
  embeds_one :dbpedia,  class_name: "DBpedia"
  embeds_one :rdfs,     class_name: "RDFS"

  @rdf_types = [[:dbpedia, :Agent],
                [:foaf, :Agent]]

  @headings = [{:rdfs => :label},
               {:foaf => :name},
               {:foaf => :givenName},
               {:foaf => :surname}]

  # model relations
  has_and_belongs_to_many :resources, index: true
  has_and_belongs_to_many :concepts, index: true

  define_scopes
  define_indexes
end