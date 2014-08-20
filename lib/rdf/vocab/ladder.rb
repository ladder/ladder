##
# Ladder Mapping Model
#

require 'rdf'

module RDF

  class Ladder < RDF::StrictVocabulary("Ladder:")
    property :model, :label => 'model', :comment => 'The name of the model Class this object belongs to'
  end

end