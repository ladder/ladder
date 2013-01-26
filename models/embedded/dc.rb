class DC
  include Model::Embedded
  bind_to RDF::DC, :type => Array, :only => [:title, :alternative, :issued, :format,
                                             :extent, :medium, :language, :identifier,
                                             :abstract, :tableOfContents, :creator,
                                             :contributor, :publisher, :spatial, :subject,
                                             :isPartOf, :hasPart, :hasVersion, :isVersionOf,
                                             :hasFormat, :isFormatOf, :isReferencedBy,
                                             :references]

  bind_to Vocab::DC, :type => Array, :only => [:DDC, :LCSH, :LCC, :RVM]
  attr_accessible :identifier
  embedded_in :resource
end