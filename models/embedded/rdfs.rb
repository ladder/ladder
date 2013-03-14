class RDFS
  include Model::Embedded

  bind_to RDF::RDFS, :type => Array, :localize => true

  embedded_in :resource
  embedded_in :agent
  embedded_in :concept
  embedded_in :group

  track_history :on => RDF::RDFS.properties#, :scope => :resource
end