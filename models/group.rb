require 'embedded'

class Group
  include Model::Core

  field :type, :type => String
  validates_inclusion_of :type, in: %w[Agent Concept Resource]

  @rdf_types = {:rdfs => [:Container]}

  @headings = [{:rdfs => :label}]

  define_scopes

  # this is basically a reverse-scope query due to one-sided relation on grouped models
  def models
    self.type.classify.constantize.where(:group_ids => self.id)
  end

  # for parity with Tire::Model::Search to allow localized normalization
  def to_hash
    self.serializable_hash
  end
end