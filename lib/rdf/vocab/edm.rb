##
# Europeana Data Model (EDM)
#
# @see http://pro.europeana.eu/edm-documentation

require 'rdf'

module RDF

  class EDM < RDF::StrictVocabulary("http://www.europeana.eu/schemas/edm/")
    # Class definitions
    property :Agent, :label => 'Agent', :comment =>
     %(This class comprises people, either individually or in groups, who have the potential to perform intentional actions for which they can be held responsible.)
    property :EuropeanaAggregation, :label => 'Europeana Aggregation', :comment =>
     %(The set of resources related to a single Cultural Heritage Object that collectively represent that object in Europeana. Such set consists of: all descriptions about the object that Europeana collects from (possibly different) content providers, including thumbnails and other forms of abstractions, as well as of the description of the object Europeana builds.)
    property :EuropeanaObject, :label => 'Europeana Object', :comment =>
     %(Any object that is the result of Europeana’s activities)
    property :Event, :label => 'Event', :comment =>
     %(An event is a change "of states in cultural, social or physical systems, regardless of scale, brought about by a series or group of coherent physical, cultural, technological or legal phenomena" (E5 Event in CIDOC CRM) or a "set of coherent phenomena or cultural manifestations bounded in time and  space" (E4 Period in CIDOC CRM))
    property :InformationResource, :label => 'Information Resource', :comment =>
     %(An information resource is a resource whose essential characteristics can be conveyed in a single message. It can be associated with a URI, it can have a representation, for example: a text is an InformationResource.)
    property :NonInformationResource, :label => 'Non-Information Resource', :comment =>
     %(All resources that are not information resources.)
    property :PhysicalThing, :label => 'Physical Thing', :comment =>
     %(A persistent physical item such as a painting, a building, a book or a stone. Persons are not items. This class represents Cultural Heritage Objects known to Europeana to be physical things (such as Mona Lisa) as well as all physical things Europeana refers to in the descriptions of Cultural Heritage Objects (such as the Rosetta Stone).)
    property :Place, :label => 'Place', :comment =>
     %(An "extent in space, in particular on the surface of the earth, in the pure sense of physics: independent from temporal phenomena and matter" (CIDOC CRM))
    property :ProvidedCHO, :label => 'Provided CHO', :comment =>
     %(This class comprises the Cultural Heritage objects that Europeana collects descriptions about.)
    property :TimeSpan, :label => 'Time Span', :comment =>
     %(The class of "abstract temporal extents, in the sense of Galilean physics, having a beginning, an end and a duration" (CIDOC CRM))
    property :WebResource, :label => 'Web Resource', :comment =>
     %(Information Resources that have at least one Web Representation and at least a URI.)

    # Property definitions
    property :aggregatedCHO, :label => 'Aggregated Cultural Heritage Object', :comment =>
     %(This property associates an ORE aggregation with the Cultural Heritage Object(s) (CHO for short) it is about.)
    property :begin, :label => 'Begin', :comment =>
     %(If the specialisations of, for example, date of birth, cannot be used then this property provides a generic start date.)
    property :currentLocation, :label => 'Current Location', :comment =>
     %(The geographic location and/or name of the repository, building, site, or other entity whose boundaries presently include the resource.)
    property :end, :label => 'End', :comment =>
     %(An edm:Agent or an edm:TimeSpan may have 0 or 1 edm:end dates and each edm:end date may be the end date of many edm:Agent or edm:TimeSpan entities.)
    property :happenedAt, :label => 'Happened At', :comment =>
     %(This property associates an event with the place at which the event happened.)
    property :hasMet, :label => 'Has Met', :comment =>
     %(edm:hasMet relates a resource with the objects or phenomena that have happened to or have happened together with the resource under consideration. We can abstractly think of history and the present as a series of “meetings” between people and other things in space-time. Therefore we name this relationship as the things the object “has met” in the course of its existence. These meetings are events in the proper sense, in which other people and things participate in any role.)
    property :hasType, :label => 'Has Type', :comment =>
     %(This property relates a resource with the concepts it belongs to in a suitable type system such as MIME or any thesaurus that captures categories of objects in a given field (e.g., the “Objects” facet in Getty’s Art and Architecture Thesaurus). It does not capture aboutness.)
    property :hasView, :label => 'Has View', :comment =>
     %(This property relates a ORE aggregation about a CHO with a web resource providing a view of that CHO. Examples of view are: a thumbnail, a textual abstract and a table of contents. The ORE aggregation may be a Europeana Aggregation, in which case the view is an object owned by Europeana (i.e., an instance of edm:EuropeanaObject) or an aggregation contributed by a content provider. In order to capture both these cases, the domain of edm:hasView is ore:Aggregation and its range is edm:WebResource)
    property :incorporates, :label => 'Incorporates', :comment =>
     %(This property captures the use of some resource to add value to another resource. Such resources may be nested, such as performing a theater play text, and then recording the performance, or creating an artful edition of a collection of poems or just aggregating various poems in an anthology. There may be no single part that contains ultimately the incorporated object, which may be dispersed in the presentation. Therefore, incorporated resources do in general not form proper parts. Incorporated resources are not part of the same resource, but are taken from other resources, and have an independent history. Therefore edm:incorporates is not a sub-property of dcterm:hasPart.)
    property :isAnnotationOf, :label => 'Is Annotation Of', :comment =>
     %(This property relates an annotation (a Europeana object) with the resource that it annotates.)
    property :isDerivativeOf, :label => 'Is Derivative Of', :comment =>
     %(This property captures a narrower notion of derivation than edm:isSimilarTo, in the sense that it relates a resource to another one, obtained by reworking, reducing, expanding, parts or the whole contents of the former, and possibly adding some minor parts. Versions have an even narrower meaning, in that it requires common identity between the related resources. Translations, summaries, abstractions etc. do not qualify as versions, but do qualify as derivatives.)
    property :isNextInSequence, :label => 'Is Next In Sequence', :comment =>
     %(edm:isNextInSequence relates two resources S and R that are ordered parts of the same resource A, and such that R comes immediately after R in the order created by their being parts of S.)
    property :isRelatedTo, :label => 'Is Related To', :comment =>
     %(edm:isRelatedTo is the most general contextual property in EDM. Contextual properties have typically to do either with the things that have happened to or together with the object under consideration, or what the object refers to by its shape, form or features in a figural or encoded form. For sake of simplicity, we include in the contextual relationships also the scholarly classification, which may have either to do with the role and cultural connections of the object in the past, or its kind of structure, substance or contents as it can be verified at present.)
    property :isRepresentationOf, :label => 'Is Representation Of', :comment =>
     %(This property associates an information resource to the resource (if any) that it represents)
    property :isSimilarTo, :label => 'Is Similar To', :comment =>
     %(The most generic derivation property, covering also the case of questionable derivation. Is Similar To asserts that parts of the contents of one resource exhibit common features with respect to ideas, shapes, structures, colors, words, plots, topics with the contents of the related resource. Those common features may be attributed to a common origin or influence (in particular for derivation), but also to more generic cultural or psychological factors.)
    property :isSuccessorOf, :label => 'Is Successor Of', :comment =>
     %(This property captures the relation between the continuation of a resource and that resource. This applies to a story, a serial, a journal etc. No content of the successor resource is identical or has a similar form with that of the precursor. The similarity is only in the context, subjects and figures of a plot. Successors typically form part of a common whole – such as a trilogy, a journal, etc.)
    property :landingPage, :label => 'Landing Page', :comment =>
     %(This property captures the relation between an aggregation representing a Cultural Heritage Object and the Web Resource representing that Object on the provider’s web site.)
    property :occurredAt, :label => 'Occured At', :comment =>
     %(This property associates an event to the smallest known time span that overlaps with the occurrence of that event)
    property :realizes, :label => 'Realizes', :comment =>
     %(This property describes a relation between a physical thing and the information resource that is contained in it, visible at it or otherwise carried by it, if applicable.)
    property :wasPresentAt, :label => 'Was Present At', :comment =>
     %(This property associates the people, things or information resources with an event at which they were present)
    property :country, :label => 'Country', :comment => ''
    property :dataProvider, :label => 'Europeana Data Provider', :comment =>
     %(This element is specifically included to allow the name of the organisation who supplies data to Europeana indirectly via an aggregator to be recorded and displayed in the portal. Aggregator names are recorded in edm:provider. If an organisation provides data directly to Europeana (i.e. not via an aggregator) the values in edm:dataProvider and edm:provider will be the same. Organisation names should be provided as an ordinary text string until the Europeana Authority File for Organisations has been established. At that point providers will be able to send an identifier from the file instead of a text string. The name provided should be the preferred form of the name in the language the provider chooses as the default language for display in the portal. Countries with multiple languages may prefer to concatenate the name in more than one language (See the example below.) Note: Europeana Data Provider is not necessarily the institution where the physical object is located.)
    property :isShownAt, :label => 'Is Shown At', :comment =>
     %(An unambiguous URL reference to the digital object on the provider’s web site in its full information context.)
    property :isShownBy, :label => 'Is Shown By', :comment =>
     %(An unambiguous URL reference to the digital object on the provider’s web site in the best available resolution/quality.)
    property :language, :label => 'Europeana Language', :comment =>
     %(A language assigned to the resource with reference to the Provider.)
    property :object, :label => 'Object', :comment =>
     %(The URL of a thumbnail representing the digital object or, if there is no such thumbnail, the URL of the digital object in the best resolution available on the web site of the data provider from which a thumbnail could be generated. This will often be the same URL as given in edm:isShownBy.)
    property :provider, :label => 'Europeana Provider', :comment =>
     %(Name of the organization that delivers data to Europeana)
    property :rights, :label => 'Europeana Rights', :comment =>
     %(Information about copyright of the digital object as specified by isShownBy and isShownAt)
    property :type, :label => 'Europeana Type', :comment =>
     %(The Europeana material type of the resource)
    property :ugc, :label => 'UGC', :comment =>
     %(This element is used to identify user generated content (also called user created content).  It should be applied to all digitised or born digital content contributed by the general public and collected by Europeana through a crowdsourcing initiative or project.)
    property :unstored, :label => 'Unstored', :comment =>
     %(This is a container element which includes all relevant information that otherwise cannot be mapped to another element in the ESE.)
    property :uri, :label => 'Europeana URI', :comment =>
     %(This is a tag created by a user through the Europeana interface.)
    property :userTag, :label => 'User Tag', :comment =>
     %(This is a tag created by a user through the Europeana interface.)
    property :year, :label => 'Europeana Year', :comment =>
     %(A point of time associated with an event in the life of the original analog or born digital object.)
  end

end