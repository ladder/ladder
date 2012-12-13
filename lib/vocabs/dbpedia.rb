##
# DBpedia vocabulary.
#
# @see http://wiki.dbpedia.org/Ontology

module Vocab

  class DBpedia < RDF::Vocabulary("http://dbpedia.org/ontology/")
    # properties are extensive and class-specific
    # NB: we use mongoid dynamic fields to access properties in this vocabulary
    # @see: http://mongoid.org/en/mongoid/docs/documents.html#dynamic_fields
  end
end