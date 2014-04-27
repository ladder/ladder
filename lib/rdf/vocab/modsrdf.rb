##
# MODS RDF vocabulary
#
# @see http://www.loc.gov/standards/mods/modsrdf/v1/

require 'rdf'

module RDF

  class MODS < RDF::StrictVocabulary("http://www.loc.gov/mods/rdf/v1/#")
    # Class definitions
    property :AdminMetadata, :label => 'Administrative Metadata', :comment =>
      %(Administrative metadata for the description)
    property :ModsResource, :label => 'MODS - A MODS Resource', :comment =>
      %(The resource which is the subject of this description.)
    property :Cartographics, :label => 'MODS - Cartographic Information', :comment =>
      %(Aggregates cartographic properties.)
    property :ClassificationGroup, :label => 'MODS - Classification Group', :comment =>
      %(For a classification whose scheme is not part of the controlled vocabulary.
        Bundles together a classification number and scheme.)
    property :IdentifierGroup, :label => 'MODS - Identifier - Typed', :comment =>
      %(Used when the identifier type is not from the controlled list.
        Bundles together an identifier and its type.)
    property :Location, :label => 'MODS - Location', :comment =>
      %(An aggregator for location properties.)
    property :LocationCopy, :label => 'MODS - Location - Copy', :comment =>
      %(An aggregator for copy properties.)
    property :NoteGroup, :label => 'MODS - Note Typed', :comment =>
      %(Aggregates a note with its type.)
    property :Part, :label => 'MODS - Part', :comment =>
      %(An aggregator for part properties.)
    property :RoleRelationship, :label => 'MODS - Role Relationship', :comment =>
      %(Aggregates a name with its role.)

    # Property definitions
    property :abstract, :label => 'Abstract', :comment =>
     %(A summary of the content of the resource.)
    property :accessCondition, :label => 'Access Condition', :comment =>
     %(Information about restrictions imposed on access to the resource.)
    property :adminMetadata, :label => 'Administrative Metadata', :comment =>
     %(Administrative metadata for the MODS description, corresponds 
       to recordInfo (MODS XML) which is, minimimally, a Class defined 
       outside of the MADS/RDF namespace. The RecordInfo Class from the 
       RecordInfo ontology is recommended.)
    property :cartographics, :label => 'Cartographics', :comment =>
     %(A geographic entity expressed in cartographic terms.)
    property :cartographicsCoordinates, :label => 'Cartographics - Coordinates', :comment => ''
    property :cartographicsProjection, :label => 'Cartographics - Projection', :comment => ''
    property :cartographicsScale, :label => 'Cartographics - Scale', :comment => ''
    property :classification, :label => 'Classification', :comment =>
     %(A designation applied to the resource that indicates the subject 
     by applying a formal system of coding and organizing resources 
     according to subject areas.)
    property :classificationGroup, :label => 'Classification Group', :comment =>
     %(Used when classification scheme is not in controlled vocabulary. 
     Bundles together the classification number with its scheme.)
    property :classificationGroupScheme, :label => 'Classification Group - Scheme', :comment =>
     %(The classification scheme)
    property :classificationGroupValue, :label => 'Classification Group - Value', :comment =>
     %(The classification value)
    property :dateCaptured, :label => 'Date Captured', :comment =>
     %(Date that the resource was digitized or a subsequent snapshot was taken.)
    property :dateCapturedEnd, :label => 'Date Captured - End', :comment =>
     %(When there is both a start and end for the capture date this is the end date.)
    property :dateCapturedStart, :label => 'Date Captured - Start', :comment =>
     %(When there is both a start and end for the capture date this is the start date.)
    property :dateCreated, :label => 'Date Created', :comment =>
     %(The resource's creation date.)
    property :dateCreatedEnd, :label => 'Date Created - End', :comment =>
     %(When there is both a start and end for the creation date this is the end date.)
    property :dateCreatedStart, :label => 'Date Created - Start', :comment =>
     %(When there is both a start and end for the creation date this is the start date.)
    property :dateModified, :label => 'Date Modified', :comment =>
     %(Date when resource was modified.)
    property :dateModifiedEnd, :label => 'Date Modified - End', :comment =>
     %(When there is both a start and end for the modification date this is the end date.)
    property :dateModifiedStart, :label => 'Date Modified - Start', :comment =>
     %(When there is both a start and end for the modification date this is the start date.)
    property :dateOfCopyright, :label => 'Date of Copyright', :comment =>
     %(Date when resource was copyrighted.)
    property :dateOfCopyrightEnd, :label => 'Date of Copyright - End', :comment => ''
    property :dateOfCopyrightStart, :label => 'Date of Copyright - Start', :comment => ''
    property :dateValid, :label => 'Date Valid', :comment =>
     %(A date when resource was valid. (Not necessarily the first or 
     last date, but this is an assertion that on that given date the 
     information was valid.))
    property :dateValidEnd, :label => 'Date Valid - End', :comment =>
     %(When the resource is valid over an interval with a start and 
       end date, this is the end date. (When start and end date are given, 
       it is an assertion that the information was valid over the course 
       of this interval. It does not necessarily assert that is was not 
       valid before the start or after the end of the interval.))
    property :dateValidStart, :label => 'Date Valid - Start', :comment =>
     %(When the resource is valid over an interval with a start and 
       end date, this is the start date. (When start and end date are given, 
       it is an assertion that the information was valid over the course 
       of this interval. It does not necessarily assert that is was not 
       valid before the start or after the end of the interval.))
    property :digitalOrigin, :label => 'Digital Origin', :comment =>
     %(a designation of the source of a digital file important to its 
       creation, use and management.)
    property :edition, :label => 'Edition', :comment =>
     %(Version of the resource.)
    property :frequency, :label => 'Frequency', :comment =>
     %(publication frequency)
    property :genre, :label => 'Genre', :comment =>
     %(The genre (or one of several genres) of the resource. Represented 
       in the MADS namespace.)
    property :identifier, :label => 'Identifier', :comment =>
     %(Identifier is a property for which all terms in the "identifier" 
       vocabulary become subproperties. Thus for example 'identifer:isbn' 
       is a subproperty saying in effect "has this ISBN" where 'isbn' is 
       a term within that vocabulary. (The prefix 'identifier:' is used 
       to denote the namespace for the "identifier" vocabulary.))
    property :identifierGroup, :label => 'Identifier Group', :comment =>
     %(Used when identifier type is not in controlled vocabulary. Bundles 
       together the identifier with its type.)
    property :identifierGroupType, :label => 'Identifier Group - Type', :comment =>
     %(The identifier type.)
    property :identifierGroupValue, :label => 'Identifier Group - Value', :comment =>
     %(The identifier value .)
    property :identifierValue, :label => 'Identifier - Value', :comment =>
     %(Used in conjuction with identifierType, when the type is not 
       from the controlled vocabulary.)
    property :issuance, :label => 'Issuance', :comment =>
     %(Describes the issuance of the resource.)
    property :languageOfResource, :label => 'Language of Resource', :comment =>
     %(The language (or one of several languages) of the resource.)
    property :locationCopy, :label => 'Location - Copy', :comment =>
     %(Information about a specific tangible instance of a bibliographic 
       resource or set which comprises one or more pieces via indication of 
       sublocation and/or locator.)
    property :locationCopyElectronicLocator, :label => 'Location - Copy -- Electronic Locator', :comment =>
     %(URI of the copy of the resource.)
    property :locationCopyEnumerationAndChronology, :label => 'Location - Copy - Enumeration And Chronology', :comment =>
     %(A summary holdings statement for the copy. A string with information 
       including volume or issue, date of publication or date of issue of a 
       component of a multi-part resource, distinguishing it from other 
       components of the same resource.)
    property :locationCopyEnumerationAndChronologyBasic, :label => 'Location - Copy - Enumeration And Chronology -- Basic', :comment =>
     %(One of three levels of enumerationAndChronology: 'basic')
    property :locationCopyEnumerationAndChronologyIndex, :label => 'Location - Copy - Enumeration And Chronology -- Index', :comment =>
     %(One of three levels of enumerationAndChronology:'index')
    property :locationCopyEnumerationAndChronologySupplement, :label => 'Location - Copy - Enumeration And Chronology -- Supplement', :comment =>
     %(One of three levels of enumerationAndChronology:'supplement')
    property :locationCopyForm, :label => 'Location - Copy -- Form', :comment =>
     %(The form of a particular copy may be indicated when the general 
       description refers to multiple forms and there is different 
       detailed holdings information associated with different forms.)
    property :locationCopyNote, :label => 'Location - Copy -- Note', :comment =>
     %(A note pertaining to a specific copy.)
    property :locationCopyShelfLocator, :label => 'Location - Copy -- Shelf Locator', :comment =>
     %(Shelfmark or other shelving designation that indicates the 
       location identifier for a copy.)
    property :locationCopySublocation, :label => 'Location - Copy -- Sublocation', :comment =>
     %(Department, division, or section of an institution holding 
       a copy of the resource.)
    property :locationOfResource, :label => 'Location', :comment =>
     %(The location (or one of several locations) at which the resource resides.)
    property :locationPhysical, :label => 'Location - Physical Location', :comment =>
     %(The institution or repository that holds the resource, or where it is available.)
    property :locationShelfLocator, :label => 'Location - Shelf Locator', :comment =>
     %(Shelfmark or other shelving designation)
    property :locationUrl, :label => 'Location - URL', :comment =>
     %(Location of the resource (a URL))
    property :mediaType, :label => 'Media Type', :comment =>
     %(An Internet Media (MIME) type e.g. text/html.)
    property :name, :label => 'Name', :comment =>
     %(A name - personal, corporate, conference, or family - associated 
       with the resource. Represented in the MADS namespace.)
    property :namePrincipal, :label => 'Name - Principle', :comment =>
     %(A name that has been distinguished as the principal name associated 
       with the resource. There should be no more than one name principal 
       name. (The rule for determining the principal name is as follows: 
       If the role associated with the name is 'creator' AND if it is the 
       only name whose role is 'creator' then it is the principal name. 
       Thus if there are more than one name, or no name, whose role is 
       'creator', then there is no principal name.) If there is a 
       principal name, and if there is a uniform title, then that name 
       and title are to be combined into a nameTitle.)
    property :note, :label => 'Note', :comment =>
     %(Textual information about the resource. This property is used when 
       no type is specified. (In contrast to hasTypedNote, whose object is 
       an aggregator that includes both the type and note.))
    property :noteGroup, :label => 'Note Group', :comment =>
     %(Used for a note with a type (other than "statement of responsibility"))
    property :noteGroupType, :label => 'NoteGroup - Type', :comment =>
     %(A property of NoteGroup - used when a type is supplied for the note. The type.)
    property :noteGroupValue, :label => 'NoteGroup - Value', :comment =>
     %(A property of noteGroup - used when a type is supplied for the note. The text of the note.)
    property :part, :label => 'Part', :comment =>
     %(Information about a physical part of the resource, including the 
       part number, its caption and title, and dimensions.)
    property :partDate, :label => 'Part Date', :comment =>
     %(Date associated with a part.)
    property :partDetailType, :label => 'Part - Detail Type', :comment =>
     %(The type of the resource part, e.g. volume, issue, page.)
    property :partEnd, :label => 'Part - End', :comment =>
     %(The value of the end of a part. For example, if unit of the part 
       has value 'page', this is the number of the last page.)
    property :partLevel, :label => 'Part - Level', :comment =>
     %(A property of a part - the level of numbering in the host/parent item.)
    property :partList, :label => 'Part - List', :comment =>
     %(A property of a part - a textual listing of the units within the part.)
    property :partName, :label => 'Part - Name', :comment =>
     %(A string that designates the part name.)
    property :partNumber, :label => 'Part - Number', :comment =>
     %(A string that designates the part number.)
    property :partOrder, :label => 'Part - Order', :comment =>
     %(An integer that designates the sequence of parts)
    property :partStart, :label => 'Part - Start', :comment =>
     %(The beginning unit of the part.)
    property :partTotal, :label => 'Part - Total', :comment =>
     %(The total number of units within a part.)
    property :partType, :label => 'Part - Type', :comment =>
     %(The segment type of a part. (When parts are included, the 
       resource is ususally a document, so the part type would be 
       the segment type of the document.))
    property :partUnit, :label => 'Part - Unit', :comment =>
     %(the unit -- e.g. page, chapter -- applying to the start, end, and total values.)
    property :physicalExtent, :label => 'Physical Extent', :comment =>
     %(a statement of the number and specific material of the units 
       of the resource that express physical extent.)
    property :physicalForm, :label => 'Physical Form', :comment =>
     %(A particular physical presentation of the resource, including 
       the physical form or medium of material for a resource. Example: oil paint)
    property :placeOfOrigin, :label => 'Place', :comment =>
     %(Place of publication/origin. Used in connection with the 
       origin of a resource, i.e., creation, publication, issuance, 
       etc. Represented as a MADS Geographic.)
    property :publisher, :label => 'Publisher', :comment =>
     %(The name of the entity that published, printed, distributed, 
       released, issued, or produced the resource.)
    property :recordContentSource, :label => 'Record Content Source', :comment =>
     %(The code or name of the organization that either created 
       the original description or modified it.)
    property :recordDescriptionStandard, :label => 'Record Description Standard', :comment =>
     %(Part of administrative metadata. The standard which designates 
       the rules used for the content of the description.)
    property :recordIdentifier, :label => 'Record Identifier', :comment =>
     %(The system control number assigned by the organization creating, 
       using, or distributing the description.)
    property :recordOrigin, :label => 'Record Origin', :comment =>
     %(Describes the origin or provenance of the description.)
    property :reformattingQuality, :label => 'Reformatting Quality', :comment =>
     %(The reformatting quality; e.g. access, preservation, replacement.)
    property :relatedConstituent, :label => 'Related item - Constituent', :comment =>
     %(Relates the described MODS resource to another MODS resource which 
       is a constituent of the described resource.)
    property :relatedFormat, :label => 'Related item - Other Format', :comment =>
     %(Relates the described MODS resource to a similar MODS resource of a different format.)
    property :relatedHost, :label => 'Related item - Host', :comment =>
     %(Relates the described MODS resource to another MODS resource 
       which is a host of the described resource.)
    property :relatedInstantiation, :label => 'Related item - Instantiation', :comment =>
     %(Relates the described resource to a another MODS resource 
       with different origination information.)
    property :relatedItem, :label => 'Related Item', :comment =>
     %(Relates the described MODS resource to another, related MODS resource.)
    property :relatedOriginal, :label => 'Related item - Original', :comment =>
     %(Relates the described MODS resource to another MODS resource 
       which is an original of the described resource.)
    property :relatedPreceding, :label => 'Related item - Preceding', :comment =>
     %(Relates the described MODS resource to a MODS resource which 
       preceded the described resource.)
    property :relatedReference, :label => 'Related item - Reference', :comment =>
     %(Relates the described MODS resource to another MODS resource 
       which the described resource references.)
    property :relatedReferencedBy, :label => 'Related item - Referenced By', :comment =>
     %(Relates the described MODS resource to another MODS resource 
       which references the described resource.)
    property :relatedReview, :label => 'Related item - Review', :comment =>
     %(Relates the described MODS resource to another MODS resource 
       which is review of the described resource.)
    property :relatedSeries, :label => 'Related item - Series', :comment =>
     %(Relates the described resource to a another MODS resource which 
       is a series of which the described resource is a part.)
    property :relatedSucceeding, :label => 'Related item - Suceeding', :comment =>
     %(Relates the described resource to a another MODS resource which 
       suceeded it.)
    property :relatedVersion, :label => 'Related Item - Other Version', :comment =>
     %(Relates the described MODS resource to another MODS resource which 
       is a different version of the described resource.)
    property :role, :label => 'Role (unbound)', :comment =>
     %(role is an abstract property, for which all terms in the relator 
       vocabulary of roles become subproperties. Thus for example 
       'relator:artist' refers to the role 'artist' within that 
       vocabulary. (The prefix 'relator:' is used to denote the namespace 
       for the "relator" vocabulary. The property 'relator:artist' 
       relates the resource to an artist associated with the resource, 
       represented as a mads name.))
    property :roleRelationship, :label => 'Role Relationship', :comment =>
     %(Binds a name to the role that the named entity played for the resource.)
    property :roleRelationshipName, :label => 'Role Relationship - Name', :comment =>
     %(The name included in a roleRelationship. The roleRelationship 
       binds an name and a role, where the name is a name associated 
       with the resource and is specified elsewhere via the hasName 
       property. This mechanism is used when the role is not part of 
       a known vocabulary. Otherwise, the relationship is expressed 
       by using the role vocabulary term as the property; for example, 
       see relator:creator.)
    property :roleRelationshipRole, :label => 'Role Relationship - Role', :comment =>
     %(The role associated with a name, where the name and role are 
       bound together in a roleRelationship.)
    property :statementOfResponsibility, :label => 'Statement of Responsibility', :comment =>
     %(A note, when the note type is "statement of responsibility")
    property :subject, :label => 'Subject', :comment =>
     %(An abstract property defined for which the various subject 
       catergories (e.g. subjectGenre, subjectTitle) are subproperties.)
    property :subjectComplex, :label => 'Subject - Complex', :comment =>
     %(A subject of the resource composed of several component subjects.)
    property :subjectGenre, :label => 'Subject - Genre Subject', :comment =>
     %(A subject of the resource which is a genre, expressed in terms 
       of a MADS GenreForm.)
    property :subjectGeographic, :label => 'Subject - Geographic', :comment =>
     %(A subject of the resource which is a geographic entity, 
       expressed in terms of a MADS Geographic.)
    property :subjectGeographicCode, :label => 'Subject - Geographic Code', :comment =>
     %(A subject of the resource which is a geographic entity, 
       expressed as a geographic code and in terms of a MADS Geographic.)
    property :subjectHierarchicalGeographic, :label => 'Subject - Hierarchical Geographic', :comment =>
     %(A subject of the resource which is a hierarchy of geographic 
       entities expressed in terms of a MADS Geographics.)
    property :subjectName, :label => 'Subject - Name Subject', :comment =>
     %(A subject of the resource which is a name, expressed in terms of a MADS Name.)
    property :subjectOccupation, :label => 'Subject - Occupation', :comment =>
     %(A subject of the resource which is an occupation, 
       expressed in terms of a MADS Occupation.)
    property :subjectTemporal, :label => 'Subject - Temporal', :comment =>
     %(A subject of the resource which is a temporal expression, 
       expressed in terms of a MADS Temporal.)
    property :subjectTitle, :label => 'Subject - Title', :comment =>
     %(A subject of the resource which is a title, expressed in terms of a MADS Title.)
    property :subjectTopic, :label => 'Subject - Topic', :comment =>
     %(A subject of the resource which is a topic, expressed in terms of a MADS Topic.)
    property :tableOfContents, :label => 'Table of Contents', :comment =>
     %(Description of the contents of the resource.)
    property :targetAudience, :label => 'Target Audience', :comment =>
     %(The target audience of the resource. Examples: adolescent, 
       adult, general, juvenile, preschool, specialized.)
    property :title, :label => 'Title', :comment =>
     %(A title for the resource. Represented as a MADS Title.)
    property :titlePrincipal, :label => 'Title - Principal', :comment =>
     %(A title which has been distinguished as the principal title. 
       (This corresponds to a MODS XML titleInfo with no type attribute.) 
       There should be no more than one principal title. Represented as a MADS Title.)
    property :titleUniform, :label => 'Title - Uniform', :comment =>
     %(A title which has been distinguished as a uniform title. 
       (This corresponds to a MODS XML titleInfo with 'type=uniform' attribute.) 
       There should be no more than one uniform title. Represented as a 
       MADS Title, or, if there is a primary name, it is represented as a MADS NameTitle.)
  end

end