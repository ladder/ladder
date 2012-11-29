##
# Dublin Core Vocabulary Encoding Schemes
#
# @see http://dublincore.org/documents/2012/06/14/dcmi-terms/?v=terms#H4

module Vocab

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
    property :RVM # @see: https://rvmweb.bibl.ulaval.ca/en/a-propos
  end

end