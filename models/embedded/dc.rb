class DC
  include Model::Embedded

  bind_to RDF::DC, :type => Array, :localize => true, :only => [:title, :alternative, :issued, :format,
                                             :extent, :medium, :language, :identifier,
                                             :abstract, :tableOfContents, :creator,
                                             :contributor, :publisher, :spatial, :subject,
                                             :isPartOf, :hasPart, :hasVersion, :isVersionOf,
                                             :hasFormat, :isFormatOf, :isReferencedBy,
                                             :references]

  bind_to Vocab::DC, :type => Array, :localize => true, :only => [:DDC, :LCSH, :LCC, :RVM]

  attr_accessible :identifier

  embedded_in :resource

  track_history :on => RDF::DC.properties + Vocab::DC.properties
end