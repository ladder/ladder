class RDFS
  include Model::Embedded
  bind_to RDF::RDFS, :type => Array, :localize => true
  embedded_in :resource
end