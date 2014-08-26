##
# Ladder Mapping Model
#

require 'rdf'

module RDF

  class Ladder < RDF::StrictVocabulary("Ladder:")
    property :model, :label => 'Model', :comment => 'The name of the Ladder::Resource Class this object belongs to.'
    property :aliases, :label => 'Aliases', :comment => 'A Hash of predicate uri-alias names for this object.'
    property :vocabs, :label => 'Vocabs', :comment => 'A list of valid RDF vocabulary URIs for this object.'
  end

end