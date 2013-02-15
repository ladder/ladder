class RDFS
  include Model::Embedded

  bind_to RDF::RDFS, :type => Array, :localize => true

  embedded_in :resource # NB: this is embedded in all models

  track_history :on => RDF::RDFS.properties
end