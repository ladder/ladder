class Group
  include Model::Core

  @rdf_types = [[:rdfs, :Container]]

  @headings = [{:rdfs => :label}]

  # model relations
  has_many :agents
  has_many :concepts
  has_many :resources

  define_scopes
end