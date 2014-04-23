module Ladder

  module Model
    
    class Embedded
      include Mongoid::Document

      # Once the document is built, bind it to the vocab's properties
      after_build :setup_vocabs
      
      private

      def setup_vocabs
        vocab = RDF::Vocabulary.from_uri(RDF::Vocabulary.uri_from_prefix metadata[:name])

        # Create a Mongoid field for each property
        vocab.predicates.each do |field|
          eigenclass.field field, :type => Array, :localize => true
        end
      end

      def eigenclass
        class << self ; self ; end
      end
    end

  end

end