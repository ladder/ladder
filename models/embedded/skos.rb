class SKOS
  include Model::Embedded

  bind_to RDF::SKOS, :type => Array, :localize => true

  embedded_in :concept

  track_history :on => RDF::SKOS.properties
end