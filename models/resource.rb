class Resource
  include Ladder::Model

  bind_to RDF::RDFS
  bind_to RDF::DC
end