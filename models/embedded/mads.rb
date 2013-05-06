class MADS
  include Model::Embedded

  bind_to Vocab::MadsRdf, :type => Array, :localize => true

  embedded_in :concept

  track_history :on => Vocab::MadsRdf.properties, :scope => :concept
end