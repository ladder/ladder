##
#  Bibliographic Framework Initiative
#
# @see http://bibframe.org/vocab/

require 'rdf'

module RDF

  class BIBFRAME < RDF::StrictVocabulary("http://bibframe.org/vocab/")
    # Class definitions
    property :Resource, :label => 'Resource', :comment =>
     %(Any BIBFRAME object.)
    property :Work, :label => 'Work', :comment =>
     %(Resource reflecting a conceptual essence of the cataloging resource.)
    property :Instance, :label => 'Instance', :comment =>
     %(Resource reflecting an individual, material embodiment of the Work.)
    property :Authority, :label => 'Authority', :comment =>
     %(Resource reflecting key authority concepts that have defined relationships reflected in the Work and Instance.)
    property :Agent, :label => 'Agent', :comment =>
     %(Entity having a role in a resource \(Person, Organization, etc.\).)
    property :Family, :label => 'Family', :comment =>
     %(Controlled family name.)
    property :Jurisdiction, :label => 'Jurisdiction', :comment =>
     %(Controlled jurisdiction (city/government, etc.) name.)
    property :Meeting, :label => 'Meeting', :comment =>
     %(Controlled corporate meeting/conference name.)
    property :Organization, :label => 'Organization', :comment =>
     %(Controlled corporate/organization name.)
    property :Person, :label => 'Person', :comment =>
     %(Controlled personal name.)
    property :Place, :label => 'Place', :comment =>
     %(Controlled term for a geographic area.)
    property :Temporal, :label => 'Temporal Concept', :comment =>
     %(Controlled term for a chronological period.)
    property :Topic, :label => 'Topic', :comment =>
     %(Controlled term for a subject/topic.)
    property :Annotation, :label => 'Annotation', :comment =>
     %(Resource that asserts additional information about other BIBFRAME resource.)
    property :CoverArt, :label => 'Cover Art Annotation', :comment =>
     %(Link to a cover illustration of an instance.)
    property :Review, :label => 'Review Annotation', :comment =>
     %(Critique of a resource, such as a book review, analysis, etc.)
    property :Summary, :label => 'Summary Annotation', :comment =>
     %(Description of the content of a resource, such as an abstract, summary, etc..)
    property :TableOfContents, :label => 'Table of Contents Annotation', :comment =>
     %(Table of Contents information for a resource)
    property :HeldItem, :label => 'Item held', :comment =>
     %(Item holding information.)
    property :HeldMaterial, :label => 'Material held', :comment =>
     %(Summary holdings information.)
    property :DescriptionAdminInfo, :label => 'Administrative metadata', :comment =>
     %(Administrative metadata associated with the graph.)
    property :Arrangement, :label => 'Organization of materials information', :comment =>
     %(Information about the organization and arrangement of a collection of items. For instance, for computer files, organization and arrangement information may be the file structure and sort sequence of a file; for visual materials, this information may be how a collection is arranged.)
    property :Category, :label => 'Category', :comment =>
     %(Generic list of values information.)
    property :Classification, :label => 'Classification Entity', :comment =>
     %(System of coding, assorting and organizing materials according to their subject.)
    property :Event, :label => 'Event Entity', :comment =>
     %(Time or place of an event.)
    property :Identifier, :label => 'Identifier', :comment =>
     %(Token or name that is associated with a resource, such as a URI, or an ISBN, etc..)
    property :IntendedAudience, :label => 'Intended Audience Information', :comment =>
     %(Information that identifies the specific intended or target audience or intellectual level for which the content described item is considered appropriate. Used to record interest and motivation levels and special learner characteristics.)
    property :Language, :label => 'Language Entity', :comment =>
     %(Language entity.)
    property :Provider, :label => 'Provider Entity', :comment =>
     %(Name of agent relating to the publication, printing, distribution, issue,release, or production of a resource.)
    property :Relator, :label => 'Relationship', :comment =>
     %(How an agent is related to a resource.)
    property :Title, :label => 'Title Entity', :comment =>
     %(Title information relating to a resource: title proper, translated title, or variant form of title.)
    property :Text, :label => 'Text', :comment =>
     %(Form of notation for language intended to be perceived visually and understood through the use of language in written or spoken form.)
    property :Cartography, :label => 'Cartography', :comment =>
     %(Resource that show spatial information, including maps, atlases, globes,digital maps, and other cartographic items.)
    property :Audio, :label => 'Audio', :comment =>
     %(Resources expressed in an audible form, including music or other sounds.)
    property :NotatedMusic, :label => 'Notated Music', :comment =>
     %(Graphic, non-realized representations of musical works intended to be perceived visually.)
    property :NotatedMovement, :label => 'Notated Movement', :comment =>
     %(Graphic, non-realized representations of movement intended to be perceived visually, e.g. dance.)
    property :Dataset, :label => 'Dataset', :comment =>
     %(Data encoded in a defined structure. Includes numeric data, environmental data,etc., used by applications software to calculate averages, correlations, etc., or to produce models, etc., but not normally displayed in its raw form.)
    property :StillImage, :label => 'Still Image', :comment =>
     %(Resource expressed through line, shape, shading, etc., intended to be perceived visually as a still image or images in two dimensions. Includes two-dimensional images and slides and transparencies.)
    property :MovingImage, :label => 'Moving Image', :comment =>
     %(Images intended to be perceived as moving, including motion pictures (using liveaction and/or animation), film and video recordings of performances, events,etc.)
    property :ThreeDimensionalObject, :label => 'Three-dimensional Object', :comment =>
     %(Resource in a form intended to be perceived visually in three-dimensions.Includes man-made objects such as models, sculptures, clothing, and toys, as well as naturally occurring objects such as specimens mounted for viewing.)
    property :Multimedia, :label => 'Software or Multimedia', :comment =>
     %(Electronic resource that is a computer program (i.e. digitally encoded instructions intended to be processed and performed by a computer) or which consist of multiple media types that are software driven. Examples include videogames and websites.)
    property :MixedMaterial, :label => 'Mixed Material', :comment =>
     %(Resource comprised of multiple types which are not driven by software. This may include materials in two or more forms that are related by virtue of their having been accumulated by or about a person or body, e.g. archival forms.)
    property :Print, :label => 'Printed', :comment =>
     %(Resource that is printed.)
    property :Manuscript, :label => 'Manuscript', :comment =>
     %(Resource that is written in handwriting or typescript. These are generally unique resources.)
    property :Archival, :label => 'Archival controlled', :comment =>
     %(Resource that is controlled archivally.)
    property :Collection, :label => 'Collection', :comment =>
     %(Aggregation of resources, generally gathered together artificially.)
    property :Tactile, :label => 'Tactile Expression', :comment =>
     %(Resource that is intended to be perceived by touch.)
    property :Electronic, :label => 'Electronic', :comment =>
     %(Resources organically created, accumulated, and/or used by a person, family, or organization in the course of conduct of affairs and preserved because of their continuing value.)
    property :Monograph, :label => 'Single unit', :comment =>
     %(Single unit cataloging resource.)
    property :MultipartMonograph, :label => 'Multiple units', :comment =>
     %(Multiple unit cataloging resource that is complete or intended to be completed within a finite number of parts.)
    property :Serial, :label => 'Serial', :comment =>
     %(Multiple unit cataloging resource issued in successive parts that has no predetermined conclusion.)
    property :Integrating, :label => 'Integrating', :comment =>
     %(Cataloging resource that is added to or changed by means of updates that do not remain discrete but are integrated into the whole.)
    property :Related, :label => 'Relationship', :comment =>
     %(How one resource is related to another.)
     
    # Property definitions
    property :label, :label => 'Property value', :comment =>
     %(Text string expressing the property value.)
    property :identifier, :label => 'Identifier', :comment =>
     %(Number or code that uniquely identifies an entity.)
    property :authorizedAccessPoint, :label => 'Authorized access point', :comment =>
     %(Controlled string form of a resource label intended to help uniquely identify it, such as a unique title or a unique name plus title.)
    property :contentCategory, :label => 'Work content category', :comment =>
     %(Categorization reflecting the fundamental form of communication in which the content is expressed and the human sense through which it is intended to be perceived.)
    property :mediaCategory, :label => 'Media category', :comment =>
     %(Categorization reflecting the general type of intermediation device required to view, play, run, etc., the content of a resource.)
    property :carrierCategory, :label => 'Instance carrier category', :comment =>
     %(Categorization reflecting the format of the storage medium and housing of a carrier.)
    property :genre, :label => 'Genre, etc.', :comment =>
     %(Genre and other general characteristice associated with genre and form.)
    property :title, :label => 'Any title', :comment =>
     %(Word, character, or group of words and/or characters that is a name given to a resource)
    property :titleStatement, :label => 'Transcribed title', :comment =>
     %(Title transcribed from an instance.)
    property :abbreviatedTitle, :label => 'Abbreviated title', :comment =>
     %(Title as abbreviated for indexing or identification.)
    property :instanceTitle, :label => 'Instance title', :comment =>
     %(Word, character, or group of words and/or characters that is the main name of an instance.)
    property :keyTitle, :label => 'Key title', :comment =>
     %(Unique title for a continuing resource that is assigned by the ISSN International Center in conjunction with an ISSN.)
    property :titleVariation, :label => 'Title variation', :comment =>
     %(Title associated with the resource that is different from the main title.)
    property :workTitle, :label => 'Work title', :comment =>
     %(Title or form of title chosen to identify the work, such as a preferred title, preferred title with additions, uniform title, etc..)
    property :partNumber, :label => 'Part title enumeration', :comment =>
     %(Part or section number of a title.)
    property :partTitle, :label => 'Part title', :comment =>
     %(Part or section name of a title.)
    property :subtitle, :label => 'Subtitle', :comment =>
     %(Word, character, or group of words and/or characters that contains the remainder of the title information after the main title.)
    property :titleAttribute, :label => 'Other attribute of title', :comment =>
     %(Other distinguishing characteristic of a work, such as version, etc..)
    property :titleQualifier, :label => 'Title qualifier', :comment =>
     %(Qualifier of title information to make it unique.)
    property :titleSource, :label => 'Title source', :comment =>
     %(Title list from which title is taken, e.g., list of abbreviated titles.)
    property :titleType, :label => 'Variant title type', :comment =>
     %(Type of title variation, e.g., acronym, cover, spine. .)
    property :titleValue, :label => 'Title', :comment =>
     %(Title being addressed.)
    property :titleVariationDate, :label => 'Variant title date', :comment =>
     %(Date or sequential designation of title variation.)
    property :formDesignation, :label => 'Form designation', :comment =>
     %(Class or genre to which a Work or Instance belongs.)
    property :legalDate, :label => 'Date of legal work', :comment =>
     %(Date of legal work, or promulgation of a law, or signing of a treaty.)
    property :musicKey, :label => 'Music Key', :comment =>
     %(Pitch and mode for music.)
    property :musicNumber, :label => 'Music number', :comment =>
     %(Serial, opus, or thematic number or code for music.)
    property :musicVersion, :label => 'Music version', :comment =>
     %(Versions such as arrangements, transcriptions, etc. of music.)
    property :originDate, :label => 'Associated title date', :comment =>
     %(Date or date range associated with the creation of the work.)
    property :originPlace, :label => 'Associated title place', :comment =>
     %(Place from which the creation of the work originated.)
    property :treatySignator, :label => 'Signatory to a treaty', :comment =>
     %(Government of other party that has formally signed a treaty.)
    property :musicMedium, :label => 'Medium of music performance', :comment =>
     %(Instrumental, vocal, and/or other medium of performance for which a musical resource was originally conceived, written or performed.)
    property :musicMediumNote, :label => 'Medium of music performance', :comment =>
     %(Instrumental, vocal, and/or other medium of performance for which a musical resource was originally conceived, written or performed.)
    property :dimensions, :label => 'Dimensions', :comment =>
     %(Measurements of the carrier or carriers and/or the container of a resource.)
    property :edition, :label => 'Edition statement', :comment =>
     %(Information identifying the edition or version of the resource.)
    property :editionResponsibility, :label => 'Edition responsibility', :comment =>
     %(Statement relating to the identification of any persons, families, or corporate bodies responsible for the edition being described.)
    property :extent, :label => 'Extent', :comment =>
     %(Number and type of units and/or subunits making up a resource.)
    property :frequency, :label => 'Frequency', :comment =>
     %(Intervals at which the issues or parts of a serial or the updates to an integrating resource are issued.)
    property :modeOfIssuance, :label => 'Mode of issuance', :comment =>
     %(Categorization reflecting whether a resource is issued in one or more parts, the way it is updated, and its intended termination.)
    property :responsibilityStatement, :label => 'Edition responsibility', :comment =>
     %(Statement relating to the identification and/or function of any persons, families, or corporate bodies responsible for the creation of, or contributing to the content of a resource.)
    property :serialFirstIssue, :label => 'Serial first issue', :comment =>
     %(Beginning date of an instance and/or the sequential designations.)
    property :serialLastIssue, :label => 'Serial last issue', :comment =>
     %(Ending date of an instance and/or the sequential designations.)
    property :providerStatement, :label => 'Provider statement', :comment =>
     %(Transcribed provider statement)
    property :provider, :label => 'Provider', :comment =>
     %(Place, name, and/or date information relating to the publication, printing, distribution, issue, release, or production instance.)
    property :distribution, :label => 'Distribution event', :comment =>
     %(Information relating to distribution of an instance.)
    property :manufacture, :label => 'Manufacture event', :comment =>
     %(Information relating to manufacture of an instance.)
    property :production, :label => 'Production event', :comment =>
     %(Information relating to production of an instance.)
    property :publication, :label => 'Publication event', :comment =>
     %(Information relating to publication of an instance.)
    property :providerRole, :label => 'Provider role', :comment =>
     %(The type of role played by the provider of an instance, e.g. production, publication, manufacture, distribution.)
    property :providerPlace, :label => 'Provider place', :comment =>
     %(Place associated with the publication, printing, distribution, issue, release or production of the instance.)
    property :providerName, :label => 'Provider name', :comment =>
     %(Name of the entity responsible for the publication, printing, distribution, issue, release or production of the instance.)
    property :providerDate, :label => 'Provider date', :comment =>
     %(Date associated with the publication, printing, distribution, issue, release or production of the instance.)
    property :copyrightDate, :label => 'Copyright date', :comment =>
     %(Date associated with a claim of protection under copyright or a similar regime.)
    property :ansi, :label => 'American National Standard Institute Number', :comment =>
     %(American National Standards Institute identifier.)
    property :coden, :label => 'CODEN', :comment =>
     %(Identifier for scientific and technical periodical titles assigned by the International CODEN Section of Chemical Abstracts Service.)
    property :doi, :label => 'Digital object identifier', :comment =>
     %(Digital Object Identifier.)
    property :ean, :label => 'International Article Identifier (EAN)', :comment =>
     %(International Article Identifier.)
    property :fingerprint, :label => 'Fingerprint identifier', :comment =>
     %(Identifier that is used to assist in the identification of antiquarian books by recording information comprising groups of characters taken from specified positions on specified pages of the book.)
    property :hdl, :label => 'Handle for a resource', :comment =>
     %(Unique and persistent identifier for digital objects developed by the Corporation for National Research Initiatives.)
    property :identifierAssigner, :label => 'Identifier assigner', :comment =>
     %(Entity that assigned the identifier.)
    property :identifierQualifier, :label => 'Identifier qualifier', :comment =>
     %(Qualifying information associated with the identifier, e.g. specifying its applicability.)
    property :identifierScheme, :label => 'Identifier scheme', :comment =>
     %(Scheme within which the identifier is unique.)
    property :identifierStatus, :label => 'Identifier status', :comment =>
     %(Indication of whether the identifier is canceled or invalid.)
    property :identifierValue, :label => 'Identifier value', :comment =>
     %(Value of the identifier.)
    property :isan, :label => 'International Standard Audiovisual Number', :comment =>
     %(International Standard Audiovisual Number.)
    property :isbn, :label => 'International Standard Bibliographic Number', :comment =>
     %(International Standard Book Number.)
    property :isbn10, :label => 'International Standard Bibliographic Number', :comment =>
     %(10 digit version of the ISBN.)
    property :isbn13, :label => 'International Standard Bibliographic Number', :comment =>
     %(13 digit version of the ISBN.)
    property :ismn, :label => 'International Standard Music Number', :comment =>
     %(International Standard Music Number.)
    property :iso, :label => 'International Organization for Standardization standard number', :comment =>
     %(International Organization for Standardization standard number.)
    property :isrc, :label => 'International Standard Recording Code', :comment =>
     %(International Standard Recording Code.)
    property :issn, :label => 'International Standard Serial Number', :comment =>
     %(International Standard Serial Number identifier.)
    property :issnL, :label => 'Linking International Standard Serial Number', :comment =>
     %(International Standard Serial Number that links together various media versions of a continuing resource.)
    property :issueNumber, :label => 'Sound recording publisher issue number', :comment =>
     %(Number used to identify the issue designation, or serial identification, assigned by a publisher to a sound recording.)
    property :istc, :label => 'International Standard Text Code', :comment =>
     %(International Standard Text code, a numbering system developed to enable the unique identification of textual works.)
    property :iswc, :label => 'International Standard Musical Work Code', :comment =>
     %(International Standard Musical Work Code, a unique, persistent reference number for the identification of musical works.)
    property :lcOverseasAcq, :label => 'Library of Congress Overseas Acquisition Program number', :comment =>
     %(Identification number assigned by the Library of Congress to works acquired through one of its overseas acquisition programs.)
    property :lccn, :label => 'Library of Congress Control Number', :comment =>
     %(Library of Congress Control Number, which identifies the resource description.)
    property :legalDeposit, :label => 'Copyright or legal deposit number', :comment =>
     %(Number assigned to a copyright or legal deposit, which Identifies a resource description.)
    property :local, :label => 'Local identifier', :comment =>
     %(Identifier established locally and not a standard number.)
    property :matrixNumber, :label => 'Sound recording publisher matrix master number', :comment =>
     %(Master from which a specific sound recording was pressed.)
    property :musicPlate, :label => 'Music publication number assigned by publisher', :comment =>
     %(Number assigned by a music publisher to a specific music publication.)
    property :musicPublisherNumber, :label => 'Other publisher number for music', :comment =>
     %(Number assigned to a music publication other than an issue, matrix, or plate number.)
    property :nban, :label => 'National bibliography agency control number', :comment =>
     %(National Bibliography Agency Number, which identifies the resource description.)
    property :nbn, :label => 'National Bibliography Number', :comment =>
     %(National Bibliography Number, which identifies the resource description.)
    property :postalRegistration, :label => 'Postal registration number', :comment =>
     %(Number assigned to a publication for which the specified postal service permits the use of a special mailing class privilege.)
    property :publisherNumber, :label => 'Other publisher assigned number', :comment =>
     %(Number assigned by a publisher that is not one of the specific defined types.)
    property :reportNumber, :label => 'Technical report number', :comment =>
     %(Identification number of a report that is not a Standard Technical Report Number.)
    property :sici, :label => 'Serial Item and Contribution Identifier', :comment =>
     %(Serial Item and Contribution Identifier.)
    property :stockNumber, :label => 'Stock number for acquisition', :comment =>
     %(Identification number such as distributor, publisher, or vendor number.)
    property :strn, :label => 'Standard Technical Report Number', :comment =>
     %(Standard Technical Report Number.)
    property :studyNumber, :label => 'Original study number assigned by the producer of a computer file', :comment =>
     %(Identification number for a computer data file.)
    property :systemNumber, :label => 'System control number', :comment =>
     %(Control number of a system other than LCCN or NBAN, which Identifies a resource description.)
    property :upc, :label => 'Universal Product Code', :comment =>
     %(Universal Product Code.)
    property :uri, :label => 'Uniform resource identifier', :comment =>
     %(Uniform Resource Identifier.)
    property :urn, :label => 'Uniform resource number', :comment =>
     %(Uniform Resource Number.)
    property :videorecordingNumber, :label => 'Publisher assigned videorecording number', :comment =>
     %(Number assigned by a publisher to a videorecording.)
    property :note, :label => 'Note', :comment =>
     %(General textual information relating to a resource.)
    property :aspectRatio, :label => 'Aspect ratio', :comment =>
     %(Proportional relationship between an image's width and its height.)
    property :awardNote, :label => 'Award note', :comment =>
     %(Information on awards associated with the described resource.)
    property :colorContent, :label => 'Color content', :comment =>
     %(Color characteristics, e.g. black and white, multicolored, etc.)
    property :contentAccessibility, :label => 'Content accessibility note', :comment =>
     %(Content that assists those with a sensory impairment for greater understanding of content, e.g., labels, captions.)
    property :contentsNote, :label => 'Contents', :comment =>
     %(List of subunits of the resource.)
    property :creditsNote, :label => 'Credits note', :comment =>
     %(Credits for persons or organizations, other than members of the cast, who have participated in the creation and/or production of the.)
    property :custodialHistory, :label => 'Custodial history', :comment =>
     %(Information about the provenance, such as origin, ownership and custodial history (chain of custody), of a resource.)
    property :dissertationDegree, :label => 'Degree', :comment =>
     %(Degree for which author was a candidate.)
    property :dissertationIdentifier, :label => 'Dissertation identifier', :comment =>
     %(Identifier assigned to a dissertation for identification purposes .)
    property :dissertationInstitution, :label => 'Degree issuing institution', :comment =>
     %(Name of degree granting institution.)
    property :dissertationNote, :label => 'Dissertation note', :comment =>
     %(Textual information about the dissertation.)
    property :dissertationYear, :label => 'Year degree awarded', :comment =>
     %(Year degree awarded.)
    property :duration, :label => 'Duration', :comment =>
     %(Information about the playing time or duration in an unstructured form, e.g., "2 hours".)
    property :findingAidNote, :label => 'Index or finding aid note', :comment =>
     %(Note about availability of an index or finding aid.)
    property :formatOfMusic, :label => 'Format of music', :comment =>
     %(Format of a musical composition, e.g. full score, condensed score, vocal score, etc.)
    property :frequencyNote, :label => 'Frequency note', :comment =>
     %(Current or former publication frequency of a resource.)
    property :geographicCoverageNote, :label => 'Geographic coverage', :comment =>
     %(Geographic entities covered by the resource.)
    property :graphicScaleNote, :label => 'Scale of graphic', :comment =>
     %(Textual information about scale, including the scale of graphic material item such as architectural drawings or three-dimensional artifacts.)
    property :illustrationNote, :label => 'Illustrative content note', :comment =>
     %(Information about illustrative material in the resource.)
    property :immediateAcquisition, :label => 'Immediate acquisition', :comment =>
     %(Information about the circumstances (e.g., source, date, method) under which the resource was directly acquired.)
    property :languageNote, :label => 'Language note', :comment =>
     %(Note concerning the language of the material or its parts.)
    property :notation, :label => 'Notation system', :comment =>
     %(Information on the alphabet, script, or symbol system used to convey the content of the resource, including specialized scripts, typefaces, tactile notation, and musical notation.)
    property :performerNote, :label => 'Performer note', :comment =>
     %(Information about the participants, players, narrators, presenters, or performers.)
    property :preferredCitation, :label => 'Preferred citation', :comment =>
     %(Citation to the resource preferred by its custodian.)
    property :soundContent, :label => 'Sound content', :comment =>
     %(Indication of whether the production of sound is an integral part of the resource.)
    property :supplementaryContentNote, :label => 'Supplementary content note', :comment =>
     %(Information on the presence of one or more bibliographies, discographies, filmographies, and/or other bibliographic references in a described resource or in accompanying material.)
    property :temporalCoverageNote, :label => 'Temporal coverage', :comment =>
     %(Time period covered by the resource.)
    property :language, :label => 'Language', :comment =>
     %(Languages associated with a resource including those for multilingual resources and translated resources.)
    property :languageOfPart, :label => 'Language of part', :comment =>
     %(Language or notation system used to convey the content of the resource \(associated with part or all of a resource\).)
    property :languageOfPartUri, :label => 'Language of part URI', :comment =>
     %(Language or notation system used to convey the content of the resource \(associated with part or all of a resource\).)
    property :languageSource, :label => 'Language source', :comment =>
     %(Language code or name list from which value is taken.)
    property :resourcePart, :label => 'Resource part', :comment =>
     %(Part of a resource for which language is being indicated.)
    property :arrangement, :label => 'Organization and Arrangement', :comment =>
     %(Information about the organization and arrangement of a collection of resources.)
    property :materialArrangement, :label => 'Arrangement of material', :comment =>
     %(Pattern of arrangement of materials within a unit.)
    property :materialHierarchicalLevel, :label => 'Hierarchical level of material', :comment =>
     %(Hierarchical position of the described materials relative to other material from the same source.)
    property :materialOrganization, :label => 'Organization of material', :comment =>
     %(Manner in which resource is divided into smaller units.)
    property :materialPart, :label => 'Part of material', :comment =>
     %(Part of the resource to which information applies.)
    property :event, :label => 'Event associated with content', :comment =>
     %(Information about the geographic area/or time period covered by an event \(e.g., a report\).)
    property :eventAgent, :label => 'Agent for event', :comment =>
     %(Person or organization associated with event.)
    property :eventDate, :label => 'Date(s) of event', :comment =>
     %(Date, time or period of event.)
    property :eventPlace, :label => 'Place of event', :comment =>
     %(Geographic area associated with event.)
    property :cartography, :label => 'Cartography data', :comment =>
     %(Cartographic data that identifies scale, coordinates, etc.)
    property :cartographicAscensionAndDeclination, :label => 'Cartographic ascension and declination', :comment =>
     %(System for identifying the location of a celestial object in the sky covered by the cartographic content of a resource using the angles of right ascension and declination.)
    property :cartographicCoordinates, :label => 'Cartographic coordinates', :comment =>
     %(Mathematical system for identifying the area covered by the cartographic content of a resource, Expressed either by means of longitude and latitude on the surface of planets or by the angles of right ascension and declination for celestial cartographic content.)
    property :cartographicEquinox, :label => 'Cartographic equinox', :comment =>
     %(One of two points of intersection of the ecliptic and the celestial equator, occupied by the sun when its declination is 0 degrees.)
    property :cartographicExclusionGRing, :label => 'Cartographic G ring area excluded', :comment =>
     %(Coordinate pairs that identify the closed non-intersecting boundary of the area contained within the G-polygon outer ring that is excluded.)
    property :cartographicOuterGRing, :label => 'Cartographic outer G ring area covered', :comment =>
     %(Coordinate pairs that identify the closed non-intersecting boundary of the area covered.)
    property :cartographicProjection, :label => 'Cartographic projection', :comment =>
     %(Method or system used to represent the surface of the Earth or of a celestial sphere on a plane.)
    property :cartographicScale, :label => 'Cartographic scale', :comment =>
     %(Ratio of the dimensions of a form contained or embodied in a resource to the dimensions of the entity it represents.)
    property :intendedAudience, :label => 'Intended audience', :comment =>
     %(Information that identifies the specific audience or intellectual level for which the content of the resource is considered appropriate.)
    property :audience, :label => 'Audience', :comment =>
     %(Information that identifies the specific audience or intellectual level for which the content of the resource is considered appropriate.)
    property :audienceAssigner, :label => 'Audience assigner', :comment =>
     %(Entity that assigned the intended audience information.)
    property :classification, :label => 'Classification', :comment =>
     %(Classification number in any scheme.)
    property :classificationDdc, :label => 'DDC Classification', :comment =>
     %(Dewey Decimal Classification number used for subject access.)
    property :classificationLcc, :label => 'LCC Classification', :comment =>
     %(Library of Congress Classification number used for subject access.)
    property :classificationNlm, :label => 'NLM classification', :comment =>
     %(National Library of Medicine Classification number used for subject access)
    property :classificationUdc, :label => 'UDC Classification', :comment =>
     %(Universal Decimal Classification number used for subject access.)
    property :classificationAssigner, :label => 'Institution assigning classification', :comment =>
     %(Entity that assigned the classification number.)
    property :classificationDesignation, :label => 'Classification designation', :comment =>
     %(Designates whether the classification number contained in the field is from the standard or optional part of the schedules or tables.)
    property :classificationEdition, :label => 'Classification scheme edition', :comment =>
     %(Edition of the classification scheme, such as full, abridged or a number, when a classification scheme designates editions.)
    property :classificationItem, :label => 'Classification item number', :comment =>
     %(Number attached to a classification number that indicates a particular item.)
    property :classificationNumber, :label => 'Classification number', :comment =>
     %(Classification number (single class number or beginning number of a span) that indicates the subject by applying a formal system of coding and organizing resources.)
    property :classificationNumberUri, :label => 'Classification number URI', :comment =>
     %(Classification number represented as a URI.)
    property :classificationScheme, :label => 'Classification scheme', :comment =>
     %(Formal scheme from which a classification number is taken.)
    property :classificationSpanEnd, :label => 'Classification number span end', :comment =>
     %(Ending number of classification number span.)
    property :classificationStatus, :label => 'Classification status', :comment =>
     %(Indicator that the classification number is canceled or invalid.)
    property :classificationTable, :label => 'Classification table identification', :comment =>
     %(DDC Table identification. Number of the table from which the classification number in a subdivision record is taken.)
    property :classificationTableSeq, :label => 'Classification table sequence number', :comment =>
     %(Sequence number or other identifier for an internal classification subarrangement or add in a classification scheme.)
    property :subject, :label => 'Subject', :comment =>
     %(Subject term(s) describing a resource.)
    property :relatedTo, :label => 'Related to another resource', :comment =>
     %(Any relationship between work or instance resources.)
    property :relatedWork, :label => 'Related Work', :comment =>
     %(General work to work relationship.)
    property :relatedInstance, :label => 'Related Instance', :comment =>
     %(General instance to instance relationship.)
    property :hasInstance, :label => 'Instance of Work', :comment =>
     %(Work has a related Instance/manifestation. For use to connect Works to Instances in the BIBFRAME structure.)
    property :instanceOf, :label => 'Instance of', :comment =>
     %(Work this resource instantiates or manifests. For use to connect Instances to Works in the BIBFRAME structure.)
    property :hasExpression, :label => 'Expressed as', :comment =>
     %(Work has a related expression. For use to connect Works under FRBR/RDA rules.)
    property :expressionOf, :label => 'Expression of', :comment =>
     %(Expression has a related work. For use to connect Works under FRBR/RDA rules.)
    property :accompaniedBy, :label => 'Accompanied by', :comment =>
     %(Resource that has an accompanying resource which adds to it)
    property :accompanies, :label => 'Accompanies', :comment =>
     %(Resource that adds to or is issued with the described resource)
    property :derivativeOf, :label => 'Is derivative of', :comment =>
     %(Work is a modification of a source work.)
    property :descriptionOf, :label => 'Is description of', :comment =>
     %(Related resource that is analyzed, commented upon, critiqued, evaluated, reviewed, or otherwise described by the resource.)
    property :hasDerivative, :label => 'Has derivative', :comment =>
     %(Work has a modification for which it is the source.)
    property :hasDescription, :label => 'Has description', :comment =>
     %(Related resource that analyzes, comments on, critiques, evaluates, reviews, or otherwise describes the resource.)
    property :hasEquivalent, :label => 'Equivalence', :comment =>
     %(Instance embodies the same expression of a work as the resource being described.)
    property :hasPart, :label => 'Has part', :comment =>
     %(Resource that is included either physically or logically contained in the described resource)
    property :partOf, :label => 'Is part of', :comment =>
     %(Resource in which the described resource is physically or logically contained.)
    property :precededBy, :label => 'Preceded By', :comment =>
     %(Resource that is precedes the resource being described \(e.g., is earlier in time or before in narrative\).)
    property :succeededBy, :label => 'Succeeded By', :comment =>
     %(Resource that succeeds the resource being described \(e.g., later in time or after in a narrative\).)
    property :issuedWith, :label => 'Issued with', :comment =>
     %(Instance that is issued on the same carrier as the manifestation being described.)
    property :otherPhysicalFormat, :label => 'Has other physical format', :comment =>
     %(Resource that is manifested in another physical carrier.)
    property :reproduction, :label => 'Has reproduction', :comment =>
     %(Instance that reproduces another Instance embodying the same work.)
    property :dataSource, :label => 'Has data source', :comment =>
     %(Work that is a data source to which the described resource is related. It may contain information about other files, printed sources, or collection procedures.)
    property :findingAid, :label => 'Has finding aid', :comment =>
     %(Relationship is to a finding aid or similar control materials for archival, visual, and manuscript resources.)
    property :index, :label => 'Index', :comment =>
     %(Work has an accompanying index)
    property :originalVersion, :label => 'Has original version', :comment =>
     %(Instance is the original version of which this resource is a reproduction.)
    property :otherEdition, :label => 'hasOtherEdition', :comment =>
     %(Resource has other available editions, for example simultaneously published language editions or reprints.)
    property :series, :label => 'Has series', :comment =>
     %(Work in which the part has been issued; the title of the larger work appears on the part.)
    property :subseries, :label => 'Has subseries', :comment =>
     %(Work, which is part of another series, in which the part has been issued.)
    property :subseriesOf, :label => 'Subseries of', :comment =>
     %(Work in which the part consistently appears; the title of the larger work appears on all issues or parts of the subseries.)
    property :supplement, :label => 'Has supplement', :comment =>
     %(Work that updates or otherwise complements the predominant work.)
    property :supplementTo, :label => 'Supplement to', :comment =>
     %(Work that is updated or otherwise complemented by the augmenting work.)
    property :translation, :label => 'Has translation', :comment =>
     %(Work that translates the text of the source entity into a language different from that of the original.)
    property :translationOf, :label => 'Translation of', :comment =>
     %(Work that has been translated, i.e., the text expressed in a language different from that of the original work.)
    property :absorbed, :label => 'Absorbed', :comment =>
     %(Work that has been incorporated into another Work)
    property :absorbedInPart, :label => 'Absorbed in part', :comment =>
     %(Work that has been partially incorporated into another work.)
    property :continues, :label => 'Continues', :comment =>
     %(Work that is continued by the content of a later work under a new title.)
    property :continuesInPart, :label => 'Continues in part', :comment =>
     %(Work that split into two or more separate works with new titles.)
    property :separatedFrom, :label => 'Separated from', :comment =>
     %(Work that spun off a part of its content to form a new work.)
    property :supersedes, :label => 'Supersedes', :comment =>
     %(Earlier work whose content has been replaced by a later work, usually because the later work contains updated or new information.)
    property :supersedesInPart, :label => 'Supersedes in part', :comment =>
     %(Earlier work whose content has been partially replaced by a later work, usually because the later work contains updated or new information.)
    property :unionOf, :label => 'Union of', :comment =>
     %(One of two or more works which came together to form a new work.)
    property :absorbedBy, :label => 'Absorbed by', :comment =>
     %(Work that incorporates another work.)
    property :absorbedInPartBy, :label => 'Absorbed in part by', :comment =>
     %(Work that incorporates part of the content of another work.)
    property :continuedBy, :label => 'Continued by', :comment =>
     %(Work whose content continues an earlier work under a new title.)
    property :continuedInPartBy, :label => 'Continued in part by', :comment =>
     %(Work part of whose content separated from an earlier work to form a new work.)
    property :mergedToForm, :label => 'Merged to form', :comment =>
     %(One of two or more works that come together to form a new work.)
    property :splitInto, :label => 'Split into', :comment =>
     %(One of two or more works resulting from the division of an earlier work into separate works.)
    property :supersededBy, :label => 'Superseded by', :comment =>
     %(Later Work used in place of an earlier work, usually because the later work contains updated or new information.)
    property :supersededInPartBy, :label => 'Superseded in part by', :comment =>
     %(Later Work used in part in place of an earlier work, usually because the later work contains updated or new information.)
    property :agent, :label => 'Associated agent', :comment =>
     %(Entity associated with a resource or element of description)
    property :creator, :label => 'Creator role', :comment =>
     %(Generalized creative responsibility role.)
    property :contributor, :label => 'Contributor role', :comment =>
     %(Generalized expressive responsibility role.)
    property :relator, :label => 'Relationship of agent', :comment =>
     %(link to role and agent information.)
    property :relatorRole, :label => 'Agent role', :comment =>
     %(Specific role of agent.)
    property :hasAuthority, :label => 'Authority information', :comment =>
     %(Link to controlled form of name or subject and other information about.)
    property :referenceAuthority, :label => 'Other authority information', :comment =>
     %(Link to authority information)
    property :authoritySource, :label => 'Authority source', :comment =>
     %(Authority list from which a value is taken.)
    property :authorityAssigner, :label => 'Authority assigner', :comment =>
     %(Entity that assigned the information.)
    property :hasAnnotation, :label => 'Has annotation', :comment =>
     %(Resource has an annotation.)
    property :annotates, :label => 'Target of Annotation', :comment =>
     %(Resource to which the annotation relates.)
    property :annotationAssertedBy, :label => 'Annotation asserted by', :comment =>
     %(Annotation was asserted by the given entity.)
    property :annotationBody, :label => 'Annotation Body', :comment =>
     %(Content of the annotation about the resource.)
    property :annotationSource, :label => 'Annotation Source', :comment =>
     %(Source of the annotation.)
    property :assertionDate, :label => 'Annotation Assertion Date', :comment =>
     %(Date when annotation was asserted.)
    property :coverArt, :label => 'Cover art', :comment =>
     %(Cover art image.)
    property :coverArtFor, :label => 'Cover art of instance', :comment =>
     %(Resource to which the cover art pertains.)
    property :coverArtThumb, :label => 'Thumbnail of cover art', :comment =>
     %(Thumbnail version of cover art image.)
    property :review, :label => 'Review content', :comment =>
     %(Review content.)
    property :reviewOf, :label => 'Resource reviewed', :comment =>
     %(Resource to which the review pertains.)
    property :startOfReview, :label => 'Review beginning', :comment =>
     %(First part of review.)
    property :startOfSummary, :label => 'Summary beginning', :comment =>
     %(First part of description.)
    property :summary, :label => 'Summary content', :comment =>
     %(Summary or abstract of the target work or instance.)
    property :summaryOf, :label => 'Resource summarized', :comment =>
     %(Resource to which the description pertains.)
    property :tableOfContents, :label => 'Table of contents content', :comment =>
     %(Table of contents of the target work or instance.)
    property :tableOfContentsFor, :label => 'Table of contents of resource', :comment =>
     %(Resource to which the table of contents pertains.)
    property :holdingFor, :label => 'Holding for', :comment =>
     %(Instance for which holding is reported)
    property :electronicLocator, :label => 'Electronic location', :comment =>
     %(Electronic location from which the resource is available.)
    property :enumerationAndChronology, :label => 'Enumeration and chronology', :comment =>
     %(Numbering and dates of holding.)
    property :heldBy, :label => 'Held by', :comment =>
     %(Entity holding the item or from which it is available)
    property :subLocation, :label => 'Held in sublocation', :comment =>
     %(Specific place within the holding entity where the item is located or made available)
    property :accessCondition, :label => 'Access condition', :comment =>
     %(Allowances and restrictions on access.)
    property :lendingPolicy, :label => 'Lending policy', :comment =>
     %(Policy statement about whether and with what restrictions the holding may be lent)
    property :reproductionPolicy, :label => 'Reproduction policy', :comment =>
     %(Policy statement about whether reproductions of the holding can be made)
    property :retentionPolicy, :label => 'Retention policy', :comment =>
     %(Policy statement about how many and/or how long the holdings are retained)
    property :componentOf, :label => 'Held item', :comment =>
     %(Link to held material)
    property :shelfMark, :label => 'Shelf Location', :comment =>
     %(Physical location, such as a call number or a special shelf/location indicator.)
    property :shelfMarkDdc, :label => 'DDC call number', :comment =>
     %(Shelf mark based on Dewey Decimal Classification.)
    property :shelfMarkLcc, :label => 'LCC call number', :comment =>
     %(Shelf mark based on Library of Congress Classification.)
    property :shelfMarkNlm, :label => 'NLM call number', :comment =>
     %(Shelf mark based on National Library of Medicine Classification.)
    property :shelfMarkScheme, :label => 'Shelf mark scheme', :comment =>
     %(Scheme from which a shelf mark is taken.)
    property :shelfMarkUdc, :label => 'UDC call number', :comment =>
     %(Shelf mark based on Universal Decimal Classification.)
    property :barcode, :label => 'Barcode', :comment =>
     %(Identification number of the physical item.)
    property :circulationStatus, :label => 'Circulation status', :comment =>
     %(Circulation status of an item.)
    property :copyNote, :label => 'Copy note', :comment =>
     %(Information about this copy.)
    property :itemId, :label => 'System item identifier', :comment =>
     %(Identification number assigned to data about one item held.)
    property :derivedFrom, :label => 'Source record', :comment =>
     %(Link to the record that was the source of the data, when applicable.)
    property :changeDate, :label => 'Description change date', :comment =>
     %(Date or date and time on which the metadata was modified.)
    property :creationDate, :label => 'Description creation date', :comment =>
     %(Date or date and time on which the original metadata first created.)
    property :descriptionConventions, :label => 'Description conventions', :comment =>
     %(Rules used for the descriptive content of the description.)
    property :descriptionLanguage, :label => 'Description language process', :comment =>
     %(Language used for the metadata.)
    property :descriptionSource, :label => 'Description source', :comment =>
     %(Entity that created or modified the metadata.)
    property :generationProcess, :label => 'Description generation process', :comment =>
     %(Indication of whether the description was machine generated or particular transformations that were applied.)
    property :categorySource, :label => 'Category source', :comment =>
     %(Category list from which value is taken.)
    property :categoryType, :label => 'Type of category', :comment =>
     %(Type of category recorded, e.g., content, genre, media, form, carrier.)
    property :categoryValue, :label => 'Category', :comment =>
     %(Category code or text.)
    property :relatedAgent, :label => 'Related agent', :comment =>
     %(Deleted when remodeled relationships (21Mar2014). See http://www.loc.gov/bibframe/docs/bibframe-authorities.html . Agent with relationship to resource.)
    property :relatedResource, :label => 'Related resource', :comment =>
     %(Deleted when remodeled relationships (21Mar2014). See http://www.loc.gov/bibframe/docs/bibframe-authorities.html . Resource with a relationship to another work or instance.)
    property :relationship, :label => 'Relationship type', :comment =>
     %(Deleted when remodeled relationships (21Mar2014). See http://www.loc.gov/bibframe/docs/bibframe-authorities.html . See http://www.loc.gov/bibframe/docs/bibframe-authorities.html . See Designation of relationship or role.)
    property :relationshipUri, :label => 'Relationship type URI', :comment =>
     %(Deleted when remodeled relationships (21Mar2014). See http://www.loc.gov/bibframe/docs/bibframe-authorities.html . Designation of relationship or role via URI.)
    property :containedIn, :label => 'Contained in', :comment =>
     %(Deleted, duplicated isPartOf. Larger work of which a part is a discrete component.)
    property :contains, :label => 'Contains', :comment =>
     %(Deleted, duplicated hasPart. Work that is a discrete component of a larger work.)
    property :category, :label => 'Category', :comment =>
     %(Structure, not property needed. Generic list of values.)
    property :place, :label => 'Associated place', :comment =>
     %(Not needed. Place entity associated with a resource or element of description.)
    property :precedes, :label => 'Precedes', :comment =>
     %(Wrong verb used for property. Replaced by precededBy. Work that precedes (e.g., is earlier in time or before in narrative) the succeeding entity.)
    property :succeeds, :label => 'Succeeds', :comment =>
     %(Wrong verb used for peoperty. Replaced by succeededBy. Work that succeeds (e.g., later in time or after in a narrative) the preceding work.)
    property :isDerivativeOf, :label => 'Is derivative of', :comment =>
     %(Property name change, replaced by derivativeOf. Work is a modification of a source work.)
    property :isDescriptionOf, :label => 'Is description of', :comment =>
     %(Property name change, replaced by descriptionOf. Related resource that is analyzed, commented upon, critiqued, evaluated, reviewed, or otherwise described by the resource.)
    property :isPartOf, :label => 'Is part of', :comment =>
     %(Property name change, replaced by partOf. Resource in which the described resource is physically or logically contained.)
    property :role, :label => 'Role term', :comment =>
     %(Specific role in string form. Deleted)
  end
end