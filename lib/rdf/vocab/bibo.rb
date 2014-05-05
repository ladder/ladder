##
# Bibliographic Ontology
#
# @see http://bibliontology.com

require 'rdf'

module RDF

  class BIBO < RDF::StrictVocabulary("http://purl.org/ontology/bibo/")
    # Class definitions
    property :AcademicArticle, :label => 'Academic Article', :comment =>
      %(A scholarly academic article, typically published in a journal.)
    property :Article, :label => 'Article', :comment =>
      %(A written composition in prose, usually nonfiction, on a specific topic, forming an independent part of a book or other publication, as a newspaper or magazine.)
    property :AudioDocument, :label => 'audio document', :comment =>
      %(An audio document; aka record.)
    property :AudioVisualDocument, :label => 'audio-visual document', :comment =>
      %(An audio-visual document; film, video, and so forth.)
    property :Bill, :label => 'Bill', :comment =>
      %(Draft legislation presented for discussion to a legal body.)
    property :Book, :label => 'Book', :comment =>
      %(A written or printed work of fiction or nonfiction, usually on sheets of paper fastened or bound together within covers.)
    property :BookSection, :label => 'Book Section', :comment =>
      %(A section of a book.)
    property :Brief, :label => 'Brief', :comment =>
      %(A written argument submitted to a court.)
    property :Chapter, :label => 'Chapter', :comment =>
      %(A chapter of a book.)
    property :Code, :label => 'Code', :comment =>
      %(A collection of statutes.)
    property :CollectedDocument, :label => 'Collected Document', :comment =>
      %(A document that simultaneously contains other documents.)
    property :Collection, :label => 'Collection', :comment =>
      %(A collection of Documents or Collections)
    property :Conference, :label => 'Conference', :comment =>
      %(A meeting for consultation or discussion.)
    property :CourtReporter, :label => 'Court Reporter', :comment =>
      %(A collection of legal cases.)
    property :Document, :label => 'Document', :comment =>
      %(A document (noun) is a bounded physical representation of body of information designed with the capacity (and usually intent) to communicate. A document may manifest symbolic, diagrammatic or sensory-representational information.)
    property :DocumentPart, :label => 'document part', :comment =>
      %(a distinct part of a larger document or collected document.)
    property :DocumentStatus, :label => 'Document Status', :comment =>
      %(The status of the publication of a document.)
    property :EditedBook, :label => 'Edited Book', :comment =>
      %(An edited book.)
    property :Email, :label => 'EMail', :comment =>
      %(A written communication addressed to a person or organization and transmitted electronically.)
    property :Event, :label => 'Event', :comment => ""
    property :Excerpt, :label => 'Excerpt', :comment =>
      %(A passage selected from a larger work.)
    property :Film, :label => 'Film', :comment =>
      %(aka movie.)
    property :Hearing, :label => 'Hearing', :comment =>
      %(An instance or a session in which testimony and arguments are presented, esp. before an official, as a judge in a lawsuit.)
    property :Image, :label => 'Image', :comment =>
      %(A document that presents visual or diagrammatic information.)
    property :Interview, :label => 'Interview', :comment =>
      %(A formalized discussion between two or more people.)
    property :Issue, :label => 'Issue', :comment =>
      %(something that is printed or published and distributed, esp. a given number of a periodical)
    property :Journal, :label => 'Journal', :comment =>
      %(A periodical of scholarly journal Articles.)
    property :LegalCaseDocument, :label => 'Legal Case Document', :comment =>
      %(A document accompanying a legal case.)
    property :LegalDecision, :label => 'Decision', :comment =>
      %(A document containing an authoritative determination (as a decree or judgment) made after consideration of facts or law.)
    property :LegalDocument, :label => 'Legal Document', :comment =>
      %(A legal document; for example, a court decision, a brief, and so forth.)
    property :Legislation, :label => 'Legislation', :comment =>
      %(A legal document proposing or enacting a law or a group of laws.)
    property :Letter, :label => 'Letter', :comment =>
      %(A written or printed communication addressed to a person or organization and usually transmitted by mail.)
    property :Magazine, :label => 'Magazine', :comment =>
      %(A periodical of magazine Articles. A magazine is a publication that is issued periodically, usually bound in a paper cover, and typically contains essays, stories, poems, etc., by many writers, and often photographs and drawings, frequently specializing in a particular subject or area, as hobbies, news, or sports.)
    property :Manual, :label => 'Manual', :comment =>
      %(A small reference book, especially one giving instructions.)
    property :Manuscript, :label => 'Manuscript', :comment =>
      %(An unpublished Document, which may also be submitted to a publisher for publication.)
    property :Map, :label => 'Map', :comment =>
      %(A graphical depiction of geographic features.)
    property :MultiVolumeBook, :label => 'Series', :comment =>
      %(A loose, thematic, collection of Documents, often Books.)
    property :Newspaper, :label => 'Newspaper', :comment =>
      %(A periodical of documents, usually issued daily or weekly, containing current news, editorials, feature articles, and usually advertising.)
    property :Note, :label => 'Note', :comment =>
      %(Notes or annotations about a resource.)
    property :Patent, :label => 'Patent', :comment =>
      %(A document describing the exclusive right granted by a government to an inventor to manufacture, use, or sell an invention for a certain number of years.)
    property :Performance, :label => 'Performance', :comment =>
      %(A public performance.)
    property :Periodical, :label => 'Periodical', :comment =>
      %(A group of related documents issued at regular intervals.)
    property :PersonalCommunication, :label => 'Personal Communication', :comment =>
      %(A communication between an agent and one or more specific recipients.)
    property :PersonalCommunicationDocument, :label => 'Personal Communication Document', :comment =>
      %(A personal communication manifested in some document.)
    property :Proceedings, :label => 'Proceedings', :comment =>
      %(A compilation of documents published from an event, such as a conference.)
    property :Quote, :label => 'Quote', :comment =>
      %(An excerpted collection of words.)
    property :ReferenceSource, :label => 'Reference Source', :comment =>
      %(A document that presents authoritative reference information, such as a dictionary or encylopedia .)
    property :Report, :label => 'Report', :comment =>
      %(A document describing an account or statement describing in detail an event, situation, or the like, usually as the result of observation, inquiry, etc..)
    property :Series, :label => 'Series', :comment =>
      %(A loose, thematic, collection of Documents, often Books.)
    property :Slide, :label => 'Slide', :comment =>
      %(A slide in a slideshow)
    property :Slideshow, :label => 'Slideshow', :comment =>
      %(A presentation of a series of slides, usually presented in front of an audience with written text and images.)
    property :Standard, :label => 'Standard', :comment =>
      %(A document describing a standard)
    property :Statute, :label => 'Statute', :comment =>
      %(A bill enacted into law.)
    property :Thesis, :label => 'Thesis', :comment =>
      %(A document created to summarize research findings associated with the completion of an academic degree.)
    property :ThesisDegree, :label => 'Thesis degree', :comment =>
      %(The academic degree of a Thesis)
    property :Webpage, :label => 'Webpage', :comment =>
      %(A web page is an online document available (at least initially) on the world wide web. A web page is written first and foremost to appear on the web, as distinct from other online resources such as books, manuscripts or audio documents which use the web primarily as a distribution mechanism alongside other more traditional methods such as print.)
    property :Website, :label => 'Website', :comment =>
      %(A group of Webpages accessible on the Web.)
    property :Workshop, :label => 'Workshop', :comment =>
      %(A seminar, discussion group, or the like, that emphasizes zxchange of ideas and the demonstration and application of techniques, skills, etc.)

    # Property definitions
    property :abstract, :label => 'abstract', :comment =>
      %(A summary of the resource.)
    property :affirmedBy, :label => 'affirmedBy', :comment =>
      %(A legal decision that affirms a ruling.)
    property :annotates, :label => 'annotates', :comment =>
      %(Critical or explanatory note for a Document.)
    property :argued, :label => 'date argued', :comment =>
      %(The date on which a legal case is argued before a court. Date is of format xsd:date)
    property :asin, :label => 'asin', :comment => ""
    property :authorList, :label => 'list of authors', :comment =>
      %(An ordered list of authors. Normally, this list is seen as a priority list that order authors by importance.)
    property :chapter, :label => 'chapter', :comment =>
      %(An chapter number)
    property :citedBy, :label => 'cited by', :comment =>
      %(Relates a document to another document that cites the first document.)
    property :cites, :label => 'cites', :comment =>
      %(Relates a document to another document that is cited by the first document as reference, comment, review, quotation or for another purpose.)
    property :coden, :label => 'coden', :comment => ""
    property :content, :label => 'content', :comment =>
      %(This property is for a plain-text rendering of the content of a Document. While the plain-text content of an entire document could be described by this property.)
    property :contributorList, :label => 'list of contributors', :comment =>
      %(An ordered list of contributors. Normally, this list is seen as a priority list that order contributors by importance.)
    property :court, :label => 'court', :comment =>
      %(A court associated with a legal document; for example, that which issues a decision.)
    property :degree, :label => 'degree', :comment =>
      %(The thesis degree.)
    property :director, :label => 'director', :comment =>
      %(A Film director.)
    property :distributor, :label => 'distributor', :comment =>
      %(Distributor of a document or a collection of documents.)
    property :doi, :label => 'doi', :comment => ""
    property :eanucc13, :label => 'eanucc13', :comment => ""
    property :edition, :label => 'edition', :comment =>
      %(The name defining a special edition of a document. Normally its a literal value composed of a version number and words.)
    property :editor, :label => 'editor', :comment =>
      %(A person having managerial and sometimes policy-making responsibility for the editorial part of a publishing firm or of a newspaper, magazine, or other publication.)
    property :editorList, :label => 'list of editors', :comment =>
      %(An ordered list of editors. Normally, this list is seen as a priority list that order editors by importance.)
    property :eissn, :label => 'eissn', :comment => ""
    property :gtin14, :label => 'gtin14', :comment => ""
    property :handle, :label => 'handle', :comment => ""
    property :identifier, :label => 'identifier', :comment => ""
    property :interviewee, :label => 'interviewee', :comment =>
      %(An agent that is interviewed by another agent.)
    property :interviewer, :label => 'interviewer', :comment =>
      %(An agent that interview another agent.)
    property :isbn, :label => 'isbn', :comment => ""
    property :isbn10, :label => 'isbn10', :comment => ""
    property :isbn13, :label => 'isbn13', :comment => ""
    property :issn, :label => 'issn', :comment => ""
    property :issue, :label => 'issue', :comment =>
      %(An issue number)
    property :issuer, :label => 'issuer', :comment =>
      %(An entity responsible for issuing often informally published documents such as press releases, reports, etc.)
    property :lccn, :label => 'lccn', :comment => ""
    property :locator, :label => 'locator', :comment =>
      %(A description (often numeric) that locates an item within a containing document or collection.)
    property :number, :label => 'number', :comment =>
      %(A generic item or document number. Not to be confused with issue number.)
    property :numPages, :label => 'number of pages', :comment =>
      %(The number of pages contained in a document)
    property :numVolumes, :label => 'number of volumes', :comment =>
      %(The number of volumes contained in a collection of documents (usually a series, periodical, etc.).)
    property :oclcnum, :label => 'oclcnum', :comment => ""
    property :organizer, :label => 'organizer', :comment =>
      %(The organizer of an event; includes conference organizers, but also government agencies or other bodies that are responsible for conducting hearings.)
    property :owner, :label => 'owner', :comment =>
      %(Owner of a document or a collection of documents.)
    property :pageEnd, :label => 'page end', :comment =>
      %(Ending page number within a continuous page range.)
    property :pages, :label => 'pages', :comment =>
      %(A string of non-contiguous page spans that locate a Document within a Collection. Example: 23-25, 34, 54-56. For continuous page ranges, use the pageStart and pageEnd properties.)
    property :pageStart, :label => 'page start', :comment =>
      %(Starting page number within a continuous page range.)
    property :performer, :label => 'performer', :comment => ''
    property :pmid, :label => 'pmid', :comment => ""
    property :prefixName, :label => 'prefix name', :comment =>
      %(The prefix of a name)
    property :presentedAt, :label => 'presented at', :comment =>
      %(Relates a document to an event; for example, a paper to a conference.)
    property :presents, :label => 'presented at', :comment =>
      %(Relates an event to associated documents; for example, conference to a paper.)
    property :producer, :label => 'producer', :comment =>
      %(Producer of a document or a collection of documents.)
    property :recipient, :label => 'recipient', :comment =>
      %(An agent that receives a communication document.)
    property :reproducedIn, :label => 'reproducedIn', :comment =>
      %(The resource in which another resource is reproduced.)
    property :reversedBy, :label => 'reversedBy', :comment =>
      %(A legal decision that reverses a ruling.)
    property :reviewOf, :label => 'review of', :comment =>
      %(Relates a review document to a reviewed thing (resource, item, etc.).)
    property :section, :label => 'section', :comment =>
      %(A section number)
    property :shortDescription, :label => 'shortDescription', :comment => ""
    property :shortTitle, :label => 'short title', :comment =>
      %(The abbreviation of a title.)
    property :sici, :label => 'sici', :comment => ""
    property :status, :label => 'status', :comment =>
      %(The publication status of (typically academic) content.)
    property :subsequentLegalDecision, :label => 'subsequentLegalDecision', :comment =>
      %(A legal decision on appeal that takes action on a case (affirming it, reversing it, etc.).)
    property :suffixName, :label => 'suffix name', :comment =>
      %(The suffix of a name)
    property :transcriptOf, :label => 'transcript of', :comment =>
      %(Relates a document to some transcribed original.)
    property :translationOf, :label => 'translation of', :comment =>
      %(Relates a translated document to the original document.)
    property :translator, :label => 'translator', :comment =>
      %(A person who translates written document from one language to another.)
    property :upc, :label => 'upc', :comment => ""
    property :uri, :label => 'uri', :comment =>
      %(Universal Resource Identifier of a document)
    property :volume, :label => 'volume', :comment =>
      %(A volume number)
  end
end