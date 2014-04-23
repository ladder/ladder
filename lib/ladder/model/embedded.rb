module Ladder

  module Model
    
    class Embedded
      include Mongoid::Document

      # Once the document is built, bind it to the vocab's properties
      after_build do |document|
        vocab = RDF::Vocabulary.from_uri(RDF::URI.from_qname metadata[:name])

        # Create a Mongoid field for each property
        vocab.predicates.each do |field_name|
          self.class.field field_name, :type => Array, :localize => true
        end
      end

    end

  end

end