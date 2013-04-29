##
# MADS RDF vocabulary
#
# @see http://www.loc.gov/standards/mads/rdf/

module Vocab

  class MADS < RDF::Vocabulary("http://www.loc.gov/mads/rdf/v1")
    property :adminMetadata
    property :affiliationEnd
    property :affiliationStart
    property :authoritativeLabel
    property :citationNote
    property :citationSource
    property :citationStatus
    property :city
    property :classification
    property :code
    property :componentList
    property :country
    property :definitionNote
    property :deletionNote
    property :deprecatedLabel
    property :editorialNote
    property :elementList
    property :elementValue
    property :email
    property :exampleNote
    property :extendedAddress
    property :extension
    property :fax
    property :fieldOfActivity
    property :hasAbbreviationVariant
    property :hasAcronymVariant
    property :hasAffiliation
    property :hasAffiliationAddress
    property :hasBroaderAuthority
    property :hasBroaderExternalAuthority
    property :hasCloseExternalAuthority
    property :hasEarlierEstablishedForm
    property :hasExactExternalAuthority
    property :hasExpansionVariant
    property :hasHiddenVariant
    property :hasIdentifier
    property :hasLaterEstablishedForm
    property :hasMADSSchemeMember
    property :hasMADSCollectionMember
    property :hasNarrowerAuthority
    property :hasNarrowerExternalAuthority
    property :hasCorporateParentAuthority
    property :hasReciprocalAuthority
    property :hasReciprocalExternalAuthority
    property :hasRelatedAuthority
    property :hasSource
    property :hasTopMemberOfMADSScheme
    property :hasTranslationVariant
    property :hasVariant
    property :hiddenLabel
    property :historyNote
    property :hours
    property :idScheme
    property :idValue
    property :identifiesRWO
    property :isIdentifiedByAuthority
    property :isMemberOfMADSCollection
    property :isMemberOfMADSScheme
    property :hasCorporateSubsidiaryAuthority
    property :isTopMemberOfMADSScheme
    property :natureOfAffiliation
    property :note
    property :organization
    property :phone
    property :postcode
    property :scopeNote
    property :see
    property :state
    property :streetAddress
    property :useFor
    property :useInstead
    property :variantLabel
  end

end