require 'embedded'

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
end