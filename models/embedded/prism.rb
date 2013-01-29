class Prism
  include Model::Embedded
  bind_to Vocab::Prism, :type => Array, :localize => true, :only => [:edition, :hasPreviousVersion, :issueIdentifier]
  embedded_in :resource
end