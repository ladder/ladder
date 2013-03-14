class Prism
  include Model::Embedded

  bind_to Vocab::Prism, :type => Array, :localize => true

  embedded_in :resource

  track_history :on => Vocab::Prism.properties, :scope => :resource
end