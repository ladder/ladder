##
# Bibliographic Ontology (Bibo) vocabulary.
#
# @see http://bibotools.googlecode.com/svn/bibo-ontology/trunk/doc/index.html

module Vocab

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

end