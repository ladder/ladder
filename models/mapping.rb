class Mapping
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content_type, :type => Array

  field :type, :type => String
  validates_inclusion_of :type, in: %w[Agent Concept Resource]

  field :vocabs, :type => Hash

  field :agents, :type => Array
  field :concepts, :type => Array
  field :resources, :type => Array
end
