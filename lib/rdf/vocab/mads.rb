##
# MADS RDF vocabulary
#
# @see http://www.loc.gov/standards/mads/rdf/

require 'rdf'

module RDF

  class MADS < RDF::StrictVocabulary("http://www.loc.gov/mads/rdf/v1#")
    # Class definitions
    property :Address, :label => 'Address', :comment => ""
    property :Affiliation, :label => 'Affiliation', :comment =>
      %(A resource that describes an individual's affiliation with an organization or group, such as the nature of the affiliation and the active dates.)
    property :Area, :label => 'Area Type', :comment =>
      %(Describes a resource whose label is a non-jurisdictional geographic entity.)
    property :Authority, :label => 'Authority', :comment =>
      %(A concept with a controlled label.)
    property :City, :label => 'City Type', :comment =>
      %(Describes a resource whose label is an inhabited place incorporated as a city, town, etc.)
    property :CitySection, :label => 'City Section Type', :comment =>
      %(Describes a resource whose label is a smaller unit within a populated place, e.g., a neighborhood, park, or street.)
    property :ComplexSubject, :label => 'Complex Subject Type', :comment =>
      %(The label of a madsrdf:ComplexSubject is the concatenation of labels from two or more madsrdf:SimpleType descriptions, except that the combination of madsrdf:SimpleType labels for the madsrdf:ComplexSubject does not meet the conditions to be the label of a madsrdf:NameTitle resource or madsrdf:HierarchicalGeographic resource.)
    property :ComplexType, :label => 'Complex Type', :comment =>
      %(madsrdf:ComplexType is a resource whose label is the concatenation of labels from two or more Authority descriptions or two or more Variant descriptions or some combination of Authority and Variant descriptions, each of a madsrdf:SimpleType.)
    property :ConferenceName, :label => 'Conference Name Type', :comment =>
      %(Describes a resource whose label represents a conference name.)
    property :Continent, :label => 'Continent Type', :comment =>
      %(Describes a resource whose label is one of seven large landmasses on Earth. These are: Asia, Africa, Europe, North America, South America, Australia, and Antarctica.)
    property :CorporateName, :label => 'Corporate Name Type', :comment =>
      %(Describes a resource whose label is the name of a corporate entity, which may include political or ecclesiastical entities.)
    property :Country, :label => 'Country Type', :comment =>
      %(Describes a resource whose label is a country, i.e. a political entity considered a country. )
    property :County, :label => 'County Type', :comment =>
      %(Describes a resource whose label is the largest local administrative unit, e.g. Warwickshire, in a country, e.g. England.)
    property :DateNameElement, :label => 'Date Name Element', :comment => ""
    property :DeprecatedAuthority, :label => 'Deprecated Authority', :comment =>
      %(A former Authority.)
    property :Element, :label => 'Element', :comment =>
      %(madsrdf:Element types describe the various parts of labels.)
    property :ExtraterrestrialArea, :label => 'Extraterrestrial Area Type', :comment =>
      %(Describes a resource whose label is any extraterrestrial entity or space, including a solar system, a galaxy, a star system, and a planet, including a geographic feature of an individual planet.)
    property :FamilyName, :label => 'Family Name Type', :comment =>
      %(Describes a resource whose label represents a family name.)
    property :FamilyNameElement, :label => 'Family Name Element', :comment => ""
    property :FullNameElement, :label => 'Fullname Element', :comment => ""
    property :GenreForm, :label => 'Genre/Form Type', :comment =>
      %(Describes a resource whose label is a genre or form term. Genre terms for textual materials designate specific kinds of materials distinguished by the style or technique of their intellectual contents; for example, biographies, catechisms, essays, hymns, or reviews. Form terms designate historically and functionally specific kinds of materials as distinguished by an examination of their physical character, characteristics of their intellectual content, or the order of information within them; for example, daybooks, diaries, directories, journals, memoranda, questionnaires, syllabi, or time sheets. In the context of graphic materials, genre headings denote categories of material distinguished by vantage point, intended purpose, characteristics of the creator, publication status, or method of representation.)
    property :GenreFormElement, :label => 'Genre/Form Element', :comment => ""
    property :Geographic, :label => 'Geographic Authority', :comment =>
      %(Describes a resource whose label represents a geographic place or feature, especially when a more precise geographic determination (City, Country, Region, etc.) cannot be made.)
    property :GeographicElement, :label => 'Geographic Element', :comment => ""
    property :GivenNameElement, :label => 'Given Name Element', :comment => ""
    property :HierarchicalGeographic, :label => 'Hierarchical Geographic Type', :comment =>
      %(A madsrdf:HierarchicalGeographic indicates that its label is the concatenation of labels from a sequence of madsrdf:Geographic types taken from one of the madsrdf:Geographic sub-classes such as madsrdf:City, madsrdf:Country, madsrdf:State, madsrdf:Region, madsrdf:Area, etc. The madsrdf:Geographic resources that constitute the madsrdf:HierarchicalGeographic should have a broader to narrower hierarchical relationship between them.)
    property :Identifier, :label => 'Other Identifier', :comment =>
      %(A madsrdf:Identifier resource describes an identifier by associating the identifier value with its type. To be used to record identifiers for a resource in the absence of URIs.)
    property :Island, :label => 'Island Type', :comment =>
      %(Describes a resource whose label is a tract of land surrounded by water and smaller than a continent but is not itself a separate country. )
    property :Language, :label => 'Language Type', :comment =>
      %(Describes a resource whose label represents a language.)
    property :LanguageElement, :label => 'Language Element', :comment => ""
    property :MADSCollection, :label => 'MADS Collection', :comment =>
      %(A madsrdf:Collection is an organizational unit, members of which will have some form of intellectually unifying theme but not to the extent that it defines an independent knowledge organization system. It aggregates madsrdf:Authority descriptions or other madsrdf:MADSCollection resources.)
    property :MADSScheme, :label => 'MADS Scheme', :comment =>
      %(MADS Scheme is an organizational unit that describes a knowledge organization system. It aggregates madsrdf:Authority descriptions and/or madsrdf:MADSCollection resources included in the knowledge organization system. Including a madsrdf:MADSCollection within a madsrdf:MADSScheme should be done with care; when a madsrdf:MADSCollection is part of a madsrdf:MADSScheme, then any madsrdf:Authority within that madsrdf:MADSCollection is effectively also in the madsrdf:MADSScheme.)
    property :MADSType, :label => 'MADS Type', :comment => ""
    property :MainTitleElement, :label => 'Main Title Element', :comment => ""
    property :Name, :label => 'Name Type', :comment =>
      %(Describes a resource whose label represents a name, especially when a more precise Name type (madsrdf:ConferenceName, masdrdf:FamilyName, etc.) cannot be identified.)
    property :NameElement, :label => 'Name Element', :comment => ""
    property :NameTitle, :label => 'Name/Title Type', :comment =>
      %(The label of a madsrdf:NameTitle resource is the concatenation of a label of a madsrdf:Name description and the label of a madsrdf:Title description. Both description types (madsrdf:Name and madsrdf:Title) are of madsrdf:SimpleType types.)
    property :NonSortElement, :label => 'Non-sort Element', :comment => ""
    property :Occupation, :label => 'Occupation Type', :comment =>
      %(Describes a resource whose label represents an occcupation.)
    property :PartNameElement, :label => 'Part Name Element', :comment => ""
    property :PartNumberElement, :label => 'Part Number Element', :comment => ""
    property :PersonalName, :label => 'Personal Name Type', :comment =>
      %(Describes a resource whose label represents a personal name.)
    property :Province, :label => 'Province Type', :comment =>
      %(Describes a resource whose label is a first order political division, e.g. Ontario, within a country, e.g. Canada. )
    property :RWO, :label => 'Real World Object', :comment =>
      %(A madsrdf:RWO is an abstract entity and identifies a Real World Object (RWO) identified by the label of a madsrdf:Authority or madsrdf:DeprecatedAuthority.)
    property :Region, :label => 'Region Type', :comment =>
      %(Describes a resource whose label is an area that has the status of a jurisdiction, usually incorporating more than one first level jurisdiction. )
    property :SimpleType, :label => 'Simple Type', :comment =>
      %(madsrdf:SimpleType is a resource with a label constituting a single word or phrase.)
    property :Source, :label => 'Source', :comment =>
      %(A resource that represents the source of information about another resource. madsrdf:Source is a type of citation.)
    property :State, :label => 'State Type', :comment =>
      %(Describes a resource whose label is a first order political division, e.g. Montana, within a country, e.g. U.S.)
    property :SubTitleElement, :label => 'Subtitle Element', :comment => ""
    property :Temporal, :label => 'Temporal Type', :comment =>
      %(Describes a resource whose label represents a time-based notion.)
    property :TemporalElement, :label => 'Temporal Element', :comment => ""
    property :TermsOfAddressNameElement, :label => 'Terms of Address Element', :comment => ""
    property :Territory, :label => 'Territory Type', :comment =>
      %(Describes a resource whose label is a geographical area belonging to or under the jurisdiction of a governmental authority. )
    property :Title, :label => 'Title Type', :comment =>
      %(Describes a resource whose label represents a title.)
    property :TitleElement, :label => 'Title Element', :comment => ""
    property :Topic, :label => 'Topic Type', :comment =>
      %(Describes a resource whose label represents a topic.)
    property :TopicElement, :label => 'Topic Element', :comment => ""
    property :Variant, :label => 'Variant', :comment =>
      %(A resource whose label is the alternate form of an Authority or Deprecated Authority.)

    # Property definitions
    property :adminMetadata, :label => 'Administrative Metadata', :comment =>
      %(This relates an Authority or Variant to its administrative metadata, which is, minimimally, a Class defined outside of the MADS/RDF namespace. The RecordInfo Class from the RecordInfo ontology is recommended.)
    property :affiliationEnd, :label => 'Affiliation Ended', :comment =>
      %(The date an individual ceased to be affiliated with an organization.)
    property :affiliationStart, :label => 'Affiliation Started', :comment =>
      %(The date an individual established an affiliation with an organization.)
    property :authoritativeLabel, :label => 'Authoritative Label', :comment =>
      %(A lexical string representing a controlled, curated label for the Authority.)
    property :changeNote, :label => 'Change Note', :comment =>
      %(A note detailing a modification to an Authority or Variant.)
    property :citationNote, :label => 'Citation Note', :comment =>
      %(A note about how the madsrdf:Source relates to the resource about which the madsrdf:Source is the information source.)
    property :citationSource, :label => 'Citation Source', :comment =>
      %(The cited resource.)
    property :citationStatus, :label => 'Citation Status', :comment =>
      %(Should use a standard term - such as 'found' or 'not found' - to indicate whether the cited resource yielded information about the resource related to the madsrdf:Source.)
    property :city, :label => 'City', :comment =>
      %(The city component of an address.)
    property :classification, :label => 'Classification', :comment =>
      %(The classification code associated with a madsrdf:Authority.)
    property :code, :label => 'Code', :comment =>
      %(A code is a string of characters associated with a the authoritative or deprecated label. It may record an historical notation once used to uniquely identify a concept.)
    property :componentList, :label => 'Component List', :comment =>
      %(madsrdf:componentList organizes the madsrdf:SimpleType resources whose labels are represented in the label of the associated madsrdf:ComplexType resource.)
    property :country, :label => 'Country', :comment =>
      %(Country associated with an address.)
    property :definitionNote, :label => 'Definition Note', :comment =>
      %(An explanation of the meaning of an Authority, DeprecatedAuthority, or Variant description.)
    property :deletionNote, :label => 'Deletion Note', :comment =>
      %(A note pertaining to the deletion of a resource.)
    property :deprecatedLabel, :label => 'Deprecated Label', :comment =>
      %(A label once considered authoritative (controlled and curated) but which is no longer.)
    property :editorialNote, :label => 'Editorial Note', :comment =>
      %(A note pertaining to the management of the label associated with the resource.)
    property :elementList, :label => 'Element List', :comment =>
      %(The madsrdf:elementList property is used to organize the various parts of labels.)
    property :elementValue, :label => 'Element Value', :comment => ""
    property :email, :label => 'Email', :comment => ""
    property :exampleNote, :label => 'Example Note', :comment =>
      %(A example of how the resource might be used.)
    property :extendedAddress, :label => 'Extended Address', :comment =>
      %(The second address line, if needed.)
    property :extension, :label => 'Extension', :comment => ""
    property :fax, :label => 'Fax', :comment =>
      %(Fax number)
    property :fieldOfActivity, :label => 'Field of Activity', :comment =>
      %(The field of activity associated with an individual.)
    property :hasAbbreviationVariant, :label => 'Has Abbreviation Variant', :comment => ""
    property :hasAcronymVariant, :label => 'Has Acronym Variant', :comment => ""
    property :hasAffiliation, :label => 'Has Affiliation', :comment =>
      %(Property to associate an individual, such as a foaf:Agent, to a group or organization with which an individual is or has been affiliated.)
    property :hasAffiliationAddress, :label => 'Has Affiliation Address', :comment =>
      %(The address of the group or organization with which an individual is associated.)
    property :hasBroaderAuthority, :label => 'Has Broader Authority', :comment => ""
    property :hasBroaderExternalAuthority, :label => 'Has Broader External Authority', :comment =>
      %(Creates a direct relationship between an Authority and a more broadly defined Authority from a different MADS Scheme.)
    property :hasCloseExternalAuthority, :label => 'Has Close External Authority', :comment =>
      %(Records a relationship between an Authority and one that is closely related from a different MADS Scheme.)
    property :hasCorporateParentAuthority, :label => 'Has Parent Organization', :comment =>
      %(Establishes a relationship between a CorporateName Authority and one of the same that is more broadly defined.)
    property :hasCorporateSubsidiaryAuthority, :label => 'Is Parent Organization Of', :comment =>
      %(Establishes a relationship between a CorporateName Authority and one of the same that is more narrowly defined.)
    property :hasEarlierEstablishedForm, :label => 'Has Earlier Established Form', :comment =>
      %(Used to reference a resource that was an earlier form. This is Related type='earlier' in MADS XML.)
    property :hasExactExternalAuthority, :label => 'Has Exact External Authority', :comment =>
      %(Records a relationship between an Authority and one to which it matches exactly but from a different MADS Scheme.)
    property :hasExpansionVariant, :label => 'Has Expansion Variant', :comment => ''
    property :hasHiddenVariant, :label => 'Has Hidden Variant', :comment =>
      %(Use for variants that are searchable, but not necessarily for display.)
    property :hasIdentifier, :label => 'Has Identifier', :comment =>
      %(Associates a resource with a madsrdf:Identifier.)
    property :hasLaterEstablishedForm, :label => 'Has Later Established Form', :comment =>
      %(Use to reference the later form of a resource. This is Related type='later' in MADS XML.)
    property :hasMADSCollectionMember, :label => 'Has MADSCollection Member', :comment =>
      %(Associates an Authority or other Collection with a madsrdf:MADSCollection.)
    property :hasMADSSchemeMember, :label => 'Has MADS Scheme Member', :comment =>
      %(Associates an Authority or Collection with a madsrdf:MADSScheme.)
    property :hasNarrowerAuthority, :label => 'Has Narrower Authority', :comment =>
      %(Creates a direct relationship between an Authority and one that is more narrowly defined.)
    property :hasNarrowerExternalAuthority, :label => 'Has Narrower External Authority', :comment =>
      %(Creates a direct relationship between an Authority and a more narrowly defined Authority from a different MADS Scheme.)
    property :hasReciprocalAuthority, :label => 'Has Reciprocal Authority', :comment =>
      %(Establishes a relationship between two Authority resources. It is reciprocal, so the relationship must be shared. This is Related type='equivalent' in MADS XML.)
    property :hasReciprocalExternalAuthority, :label => 'Has Reciprocal External Authority', :comment =>
      %(Establishes a relationship between an Authority and one from a different MADS Scheme. It is reciprocal, so the relationship must be shared.)
    property :hasRelatedAuthority, :label => 'Has Related Authority', :comment =>
      %(Unless the relationship can be more specifically identified, use 'hasRelatedAuthority.')
    property :hasSource, :label => 'Has Source', :comment =>
      %(Associates a resource description with its Source.)
    property :hasTopMemberOfMADSScheme, :label => 'Has Top Member of MADS Scheme', :comment =>
      %(Identifies an Authority that is at the top of the hierarchy of authorities within the MADS Scheme.)
    property :hasTranslationVariant, :label => 'Has Translation Variant', :comment =>
      %(A Variant whose label represents a translation of that of the authoritative label.)
    property :hasVariant, :label => 'Has Variant', :comment =>
      %(Associates a Variant with an Authority or Deprecrated Authority. Unless the variant type can be more specifically identified, use 'hasVariant.')
    property :hiddenLabel, :label => 'Hidden Label', :comment =>
      %(A label entered for discovery purposes but not shown.)
    property :historyNote, :label => 'History Note', :comment =>
      %(A note pertaining to the history of the resource.)
    property :hours, :label => 'Hours', :comment => ""
    property :idScheme, :label => 'Identifier Scheme', :comment =>
      %(The scheme associated with the identifier. For example, \"LCCN\" would be used when the Identifier Value (madsrdf:idValue) is a LC Control Number.)
    property :idValue, :label => 'Identifier Value', :comment =>
      %(The value of the identifier conforming to the Identifier Scheme syntax.)
    property :identifiesRWO, :label => 'Identifies RWO', :comment =>
      %(Associates a madsrdf:Authority with the Real World Object that is the subject of the authority's label.)
    property :isIdentifiedByAuthority, :label => 'Is Identified By Authority', :comment =>
      %(Associates a Real World Object with its Authority description.)
    property :isMemberOfMADSCollection, :label => 'Is Member Of MADSCollection', :comment =>
      %(Associates a Collection with a madsrdf:Authority or another madsrdf:MADSCollection.)
    property :isMemberOfMADSScheme, :label => 'Is Member of MADS Scheme', :comment => ''
    property :isTopMemberOfMADSScheme, :label => 'Is Top Member of MADS Scheme', :comment =>
      %(Identifies a MADS Scheme in which the Authority is at the top of the hierarchy.)
    property :natureOfAffiliation, :label => 'Nature of Affiliation', :comment =>
      %(Records the individual's role or position in the organization with which the individual is affiliated. A \"job title\" might be appropriate.)
    property :note, :label => 'Note', :comment =>
      %(A note about the resource.)
    property :organization, :label => 'Organization or Group', :comment =>
      %(The group or organization with which an individual is associated.)
    property :phone, :label => 'Phone', :comment => ""
    property :postcode, :label => 'Post Code / Zip Code', :comment => ""
    property :scopeNote, :label => 'Scope Note', :comment => ""
    property :see, :label => 'See Also', :comment =>
      %(Denotes a relationship between an Authority and/or DeprecatedAuthority. The relationship may or may or may not be reciprocated and there is no certainty that the related resource will further illuminate the original resource.)
    property :state, :label => 'State', :comment =>
      %(The state associated with an address.)
    property :streetAddress, :label => 'Street Address', :comment =>
      %(First line of address. For second line, use madsrdf:extendedAddress.)
    property :useFor, :label => 'Use For', :comment =>
      %(\"Use [This Resource] For.\" Traditional \"USE FOR\" reference.)
    property :useInstead, :label => 'Use Instead', :comment =>
      %(\"Use [This Other Resource] Instead.\" Traditional \"USE\" reference.)
    property :variantLabel, :label => 'Variant Label', :comment =>
      %(The lexical, variant form of an authoritative label.)
	end
end