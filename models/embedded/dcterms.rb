class DCTerms
  include Model::Embedded

  bind_to RDF::DC, :type => Array, :localize => true
  bind_to Vocab::DC, :type => Array, :localize => true

  attr_accessible :identifier

  embedded_in :resource

  track_history :on => RDF::DC.properties + Vocab::DC.properties, :scope => :resource
end