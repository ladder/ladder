#
# Application-specific RDF::Vocabulary definitions
#

module LadderVocab
  ##
  # Bibliographic Ontology (Bibo) vocabulary.
  #
  # @see http://bibotools.googlecode.com/svn/bibo-ontology/trunk/doc/index.html
  class Bibo < RDF::Vocabulary("http://purl.org/ontology/bibo/")
    property :abstract
    property :argued
    property :asin
    property :chapter
    property :coden
    property :content
    property :doi
    property :eanucc13
    property :edition
    property :eissn
    property :gtin14
    property :handle
    property :identifier
    property :isbn
    property :isbn10
    property :isbn13
    property :issn
    property :issue
    property :lccn
    property :locator
    property :number
    property :numPages
    property :numVolumes
    property :oclcnum
    property :pageEnd
    property :pages
    property :pageStart
    property :pmid
    property :prefixName
    property :section
    property :shortDescription
    property :shortTitle
    property :sici
    property :suffixName
    property :upc
    property :uri
    property :volume
  end

  ##
  # PRISM (Prism) vocabulary.
  #
  # @see http://www.prismstandard.org/specifications/2.1/PRISM_prism_namespace_2.1.pdf
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

  ##
  # Dublin Core Vocabulary Encoding Schemes
  #
  # @see http://dublincore.org/documents/2012/06/14/dcmi-terms/?v=terms#H4
  class DCVocab < RDF::Vocabulary("http://purl.org/dc/terms/")
    property :DCMIType
    property :DDC
    property :IMT
    property :LCC
    property :LCSH
    property :MESH
    property :NLM
    property :TGN
    property :UDC
  end

  ##
  # VCard vocabulary
  #
  # @see http://semanticweb.org/wiki/HCard or http://microformats.org/wiki/hcard
  class VCard < RDF::Vocabulary("http://www.w3.org/2006/vcard/ns")
    property :fn
    property :'family-name'
    property :'given-name'
    property :'additional-name'
    property :'honorific-prefix'
    property :'honorific-suffix'
    property :'post-office-box'
    property :'extended-address'
    property :'street-address'
    property :locality
    property :region
    property :'postal-code'
    property :'country-name'
    property :type
    property :value
    property :agent
    property :bday
    property :category
    property :class
    property :email
    property :geo
    property :latitude
    property :longitude
    property :key
    property :label
    property :logo
    property :mailer
    property :nickname
    property :note
    property :'organization-name'
    property :'organization-unit'
    property :photo
    property :rev
    property :role
    property :'sort-string'
    property :sound
    property :tel
    property :title
    property :tz
    property :uid
    property :url

    def self.aliases
      # camelCase aliases
      map = {:'family-name' => :familyName,
             :'given-name' => :givenName,
             :'additional-name' => :additionalName,
             :'honorific-prefix' => :honorificPrefix,
             :'honorific-suffix' => :honorificSuffix,
             :'post-office-box' => :postOfficeBox,
             :'extended-address' => :extendedAddress,
             :'street-address' => :streetAddress,
             :'postal-code' => :postalCode,
             :'country-name' => :countryName,
             :'organization-name' => :organizationName,
             :'organization-unit' => :organizationUnit,
             :'sort-string' => :sortString
      }
    end
  end

end