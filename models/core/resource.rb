class Resource
  include Model::Core

  # embedded RDF vocabularies
  embeds_one :dcterms,  class_name: 'DCTerms',  cascade_callbacks: true, autobuild: false
  embeds_one :bibo,     class_name: 'Bibo',     cascade_callbacks: true, autobuild: false
  embeds_one :prism,    class_name: 'Prism',    cascade_callbacks: true, autobuild: false

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

  # Enable history tracking for embedded documents
  track_history :on => vocabs.keys

  define_scopes
end