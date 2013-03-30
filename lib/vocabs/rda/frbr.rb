##
# FRBR Entities (RDF Classes) for RDA
#
# @see http://metadataregistry.org/schema/show/id/14.html

module Vocab

  class RDAFRBR < RDF::Vocabulary("http://rdvocab.info/uri/schema/FRBRentitiesRDA/")
    # NB: these are *classes*, NOT properties; this is currently used for enumeration
    property :Agent
    property :Concept
    property :CorporateBody
    property :Event
    property :Expression
    property :Family
    property :Item
    property :Manifestation
    property :Name
    property :Object
    property :Person
    property :Place
    property :Subject
    property :Work
  end

end
