##
# RDA Group 3 Element Vocabulary
#
# @see http://metadataregistry.org/schema/show/id/16.html

module Vocab

  class RDAGroup2 < RDF::Vocabulary("http://rdvocab.info/ElementsGr3/")
    property :cataloguersNote
    property :identifierForTheConcept
    property :identifierForTheEvent
    property :identifierForTheObject
    property :identifierForThePlace
    property :nameOfTheEvent
    property :nameOfTheObject
    property :nameOfThePlace
    property :preferredNameForTheEvent
    property :preferredNameForTheObject
    property :preferredNameForThePlace
    property :preferredTermForTheConcept
    property :sourceConsulted
    property :statusOfIdentification
    property :termForTheConcept
    property :variantNameForTheEvent
    property :variantNameForTheObject
    property :variantNameForThePlace
    property :variantTermForTheConcept
  end

end
