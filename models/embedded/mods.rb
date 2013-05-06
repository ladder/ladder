class MODS
  include Model::Embedded

  bind_to Vocab::ModsResource, :type => Array, :localize => true

  embedded_in :resource

  track_history :on => Vocab::ModsResource.properties, :scope => :resource
end