##
# Bibframe Vocabulary
#
# @see http://bibframe.org/vocab/

module Vocab

  class Bibframe < RDF::Vocabulary("http://bibframe.org/vocab/")
    # NB: properties are NOT namespaced, so they are all grouped together here

    # from: http://bibframe.org/vocab/Resource.html
    property :authorizedAccessPoint
    property :description
    property :identifier
    property :label
    property :relatedResource

      # from: http://bibframe.org/vocab/Authority.html
      property :hasAnnotation

        # from: http://bibframe.org/vocab/Agent.html
        property :descriptionRole
        property :isni
        property :orcid
        property :resourceRole
        property :viaf

        # from: http://bibframe.org/vocab/ClassificationEntity.html
        property :classAssigner
        property :classCopy
        property :classEdition
        property :classItem
        property :classNumber
        property :classNumberSpanEnd
        property :classScheme
        property :classSchemePart
        property :classStatus
        property :classTable
        property :classTableSeq

      # from: http://bibframe.org/vocab/Annotation.html
      property :annotates
      property :annotationAssertedBy
      property :annotationBody

        # from: http://bibframe.org/vocab/Holding.html
        property :callno
        property :'callno-ddc'
        property :'callno-lcc'
        property :'callno-udc'

    # from: http://bibframe.org/vocab/Instance.html
      property :abbreviatedTitle
      property :ansi
      property :aspectRatio
      property :associatedAgent
      property :awardNote
      property :coden
      property :colorContent
      property :contentAccessabilityNote
      property :creditsNote
      property :doi
      property :duration
      property :ean
      property :fingerprint
      property :formatOfMusic
      property :hasAnnotation
      property :hdl
      property :illustrativeContentNote
      property :instanceOf
      property :intendedAudience
      property :isbn
      property :ismn
      property :iso
      property :isrc
      property :issn
      property :'issue-number'
      property :language
      property :'lc-overseas-acq'
      property :lccn
      property :'legal-deposit'
      property :local
      property :'matrix-number'
      property :mediumOfMusic
      property :'music-plate'
      property :'music-publisher'
      property :nban
      property :nbn
      property :note
      property :organizationSystem
      property :performerNote
      property :'postal-registration'
      property :pubDate
      property :'publisher-number'
      property :'report-number'
      property :sici
      property :soundContent
      property :statementOfResponsibility
      property :'stock-number'
      property :strn
      property :'study-number'
      property :summary
      property :supplementaryContentNote
      property :'system-number'
      property :title
      property :titlePart
      property :upc
      property :uri
      property :urn
      property :variantTitle
      property :'videorecording-identifier'

      # from: http://bibframe.org/vocab/Work.html
      property :abbreviatedTitle
      property :associatedAgent
      property :class
      property :'class-ddc'
      property :'class-lcc'
      property :'class-udc'
      property :contentCoverage
      property :contentNature
      property :creditsNote
      property :hasAnnotation
      property :intendedAudience
      property :isan
      property :'issn-l'
      property :istc
      property :iswc
      property :language
      property :languageOfWork
      property :mediumOfMusic
      property :note
      property :performerNote
      property :relatedWork
      property :subject
      property :summary
      property :title
      property :titlePart
      property :uniformTitle
      property :variantTitle

        # from: http://bibframe.org/vocab/Cartographic.html
        property :cartographicAscensionAndDeclination
        property :cartographicCoordinates
        property :cartographicEquinox
        property :cartographicExclusionGRing
        property :cartographicNote
        property :cartographicOuterGRing
        property :cartographicProjection
        property :cartographicScale

        # from: http://bibframe.org/vocab/Dissertation.html
        property :dissertationDegree
        property :dissertationIdentifier
        property :dissertationInstitution
        property :dissertationNote
        property :dissertationYear

    def self.aliases
      # camelCase aliases
      map = {# Holding
             :'callno-ddc' => :callnoDDC,
             :'callno-lcc' => :callnoLCC,
             :'callno-udc' => :callnoUDC,

             # Instance
             :'issue-number'              => :issueNumber,
             :'lc-overseas-acq'           => :lcOverseasAcq,
             :'legal-deposit'             => :legalDeposit,
             :'matrix-number'             => :matrixNumber,
             :'music-plate'               => :musicPlate,
             :'music-publisher'           => :musicPublisher,
             :'postal-registration'       => :postalRegistration,
             :'publisher-number'          => :publicherNumber,
             :'report-number'             => :reportNumber,
             :'stock-number'              => :stockNumber,
             :'study-number'              => :studyNumber,
             :'system-number'             => :systemNumber,
             :'videorecording-identifier' => :videorecordingIdentifier,

             # Work
             :'class-ddc' => :classDDC,
             :'class-lcc' => :classLCC,
             :'class-udc' => :classUDC,
             :'issn-l'    => :issnL
      }
    end
  end

end
