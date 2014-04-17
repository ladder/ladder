module Ladder

  module Model
    
    class Embedded
      include Mongoid::Document

      # Once the document is built, bind it to the vocab's properties
      after_build do |document|
        vocab = RDF::Vocabulary.from_uri(self.to_uri)

        # Create a Mongoid field for each property
        vocab.predicates.each do |field|
          self.class.field field, :type => Array, :localize => true
        end
      end

      def to_uri
        RDF::URI.from_qname metadata[:name] unless metadata.nil?
      end

    end

  end

end