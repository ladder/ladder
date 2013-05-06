class Mapping
  include Mongoid::Pagination
  include Mongoid::Document
  include Mongoid::History::Trackable

  include Mongoid::Timestamps
  index({ created_at: 1 })
  index({ updated_at: 1 })

  field :content_type, :type => Array

  field :type, :type => String
  validates_inclusion_of :type, in: %w[Agent Concept Resource]

  field :vocabs, :type => Hash

  field :agents, :type => Array
  field :concepts, :type => Array
  field :resources, :type => Array
end
