class Mapping
  include Mongoid::Pagination
  include Mongoid::Document
  include Mongoid::History::Trackable

  include Mongoid::Timestamps
  index({ created_at: 1 })
  index({ updated_at: 1 })

  field :type, :type => String
  validates_inclusion_of :type, in: %w[Agent Concept Resource]

  field :content_type, :type => Array

  field :vocabs, :type => Hash, :default => {}

  field :agents, :type => Array, :default => []
  field :concepts, :type => Array, :default => []
  field :resources, :type => Array, :default => []
end
