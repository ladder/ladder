##
# PRISM (Prism) vocabulary.
#
# @see http://www.prismstandard.org/specifications/2.1/PRISM_prism_namespace_2.1.pdf

module Vocab

  class Prism < RDF::Vocabulary("http://prismstandard.org/namespaces/1.2/basic/")
    property :aggregationType
    property :alternateTitle
    property :byteCount
    property :channel
    property :complianceProfile
    property :copyright
    property :corporateEntity
    property :coverDate
    property :coverDisplayDate
    property :creationDate
    property :dateReceived
    property :distributor
    property :doi
    property :edition
    property :eIssn
    property :embargoDate
    property :endingPage
    property :event
    property :expirationDate
    property :genre
    property :hasAlternative
    property :hasCorrection
    property :hasPreviousVersion
    property :hasTranslation
    property :industry
    property :isbn
    property :isCorrectionOf
    property :issn
    property :issueIdentifier
    property :issueName
    property :isTranslationOf
    property :keyword
    property :killDate
    property :location
    property :metadataContainer
    property :modificationDate
    property :number
    property :object
    property :organization
    property :originPlatform
    property :pageRange
    property :person
    property :publicationDate
    property :publicationName
    property :rightsAgent
    property :section
    property :startingPage
    property :subchannel1
    property :subchannel2
    property :subchannel3
    property :subchannel4
    property :subsection1
    property :subsection2
    property :subsection3
    property :subsection4
    property :teaser
    property :ticker
    property :timePeriod
    property :url
    property :versionIdentifier
    property :volume
    property :wordCount
  end

end