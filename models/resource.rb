require 'embedded'

class Resource
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :dcterms,  class_name: 'DC'#,     autobuild: true
  embeds_one :bibo,     class_name: 'Bibo'#,   autobuild: true
  embeds_one :prism,    class_name: 'Prism'#,  autobuild: true

  @rdf_types = [[:dbpedia, :Work],
                [:schema, :CreativeWork],
                [:dc, :BibliographicResource],
                [:bibo, :Document]]

  @headings = [{:rdfs => :label},
               {:dcterms => :title},
               {:dcterms => :alternative}]

  # imported data objects
  has_many :files, class_name: 'Model::File'

  # model relations
  has_and_belongs_to_many :groups, index: true
  has_and_belongs_to_many :agents, index: true
  has_and_belongs_to_many :concepts, index: true

  define_scopes
end