require 'embedded'

class Group
  include Model::Core

  field :type

  @rdf_types = {:rdfs => [:Container]}

  @headings = [{:rdfs => :label}]

  # model relations
  has_and_belongs_to_many :agents
  has_and_belongs_to_many :concepts
  has_and_belongs_to_many :resources

#  track_history

  define_scopes
end