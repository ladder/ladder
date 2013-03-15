require 'embedded'

class Group
  include Model::Core

  field :type

  @rdf_types = {:rdfs => [:Container]}

  @headings = [{:rdfs => :label}]

  define_scopes
end