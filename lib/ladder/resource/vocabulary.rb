module Ladder

  module Resource
    
    class Vocabulary
      include Mongoid::Document

      # Once the document is built, bind it to the vocab's properties
      after_build :setup_vocabs
      
      private

      def setup_vocabs
        vocab = ::RDF::Vocabulary.find(::RDF::Vocabulary.expand_pname(metadata[:name]))

        # Create a Mongoid field for each property
        vocab.properties.each do |property|
          eigenclass.field property.qname.last, type: Array, localize: true
        end
      end

      def eigenclass
        class << self ; self ; end
      end
    end

  end

end