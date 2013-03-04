class Bibo
  include Model::Embedded

  bind_to Vocab::Bibo, :type => Array, :localize => true

  embedded_in :resource

  track_history :on => Vocab::Bibo.properties
end