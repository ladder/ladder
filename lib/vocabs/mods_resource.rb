##
# MODS RDF vocabulary
#
# @see http://www.loc.gov/standards/mods/modsrdf/

module Vocab

  class ModsResource < RDF::Vocabulary("http://www.loc.gov/mods/rdf/v1#")
    property :abstract
    property :accessCondition
    property :adminMetadata
    property :cartographics
    property :classification
    property :classificationGroup
    property :dateCapturedEnd
    property :dateCapturedStart
    property :dateCreatedEnd
    property :dateCreatedStart
    property :dateModifiedEnd
    property :dateModifiedStart
    property :dateOfCopyrightEnd
    property :dateOfCopyrightStart
    property :dateValidEnd
    property :dateValidStart
    property :digitalOrigin
    property :edition
    property :frequency
    property :genre
    property :identifier
    property :identifierGroup
    property :issuance
    property :languageOfResource
    property :locationOfResource
    property :mediaType
    property :name
    property :namePrincipal
    property :note
    property :noteGroup
    property :part
    property :physicalExtent
    property :physicalForm
    property :placeOfOrigin
    property :publisher
    property :reformattingQuality
    property :relatedConstituent
    property :relatedFormat
    property :relatedHost
    property :relatedInstantiation
    property :relatedItem
    property :relatedOriginal
    property :relatedPreceding
    property :relatedReference
    property :relatedReferencedBy
    property :relatedReview
    property :relatedSeries
    property :relatedSucceeding
    property :relatedVersion
    property :role
    property :roleRelationship
    property :statementOfResponsibility
    property :subject
    property :subjectComplex
    property :subjectGenre
    property :subjectGeographic
    property :subjectGeographicCode
    property :subjectHierarchicalGeographic
    property :subjectName
    property :subjectOccupation
    property :subjectTemporal
    property :subjectTitle
    property :subjectTopic
    property :tableOfContents
    property :targetAudience
    property :title
    property :titlePrincipal
    property :titleUniform
  end

end