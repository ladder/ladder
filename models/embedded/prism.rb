class Prism
  include Model::Embedded
  bind_to Vocab::Prism, :type => Array, :only => [:edition, :hasPreviousVersion, :issueIdentifier]
  embedded_in :resource
end