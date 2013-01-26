class RDFS
  include Model::Embedded
  bind_to RDF::RDFS, :type => Array
  embedded_in :resource
end