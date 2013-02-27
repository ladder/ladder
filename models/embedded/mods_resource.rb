class ModsResource
  include Model::Embedded

  bind_to Vocab::ModsResource, :type => Array, :localize => true, :only => [:note]

  embedded_in :resource

  track_history :on => Vocab::ModsResource.properties
end