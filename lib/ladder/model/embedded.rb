module Ladder

  module Model
    
    class Embedded
      include Mongoid::Document

      # Once the document is built, bind it to the vocab's properties
      after_build do |document|
        uri = self.to_uri
        vocab = RDF::Vocabulary.find {|vocab| vocab.to_uri == uri}
        fields = (vocab.public_methods - RDF::Vocabulary.methods - [:properties])

        fields.each do |f|
          self.class.field f.to_sym, :type => Array, :localize => true
        end
      end
        
      def to_uri
        # NB: this requires the RDF::URI patch
        RDF::URI.from_qname metadata[:name] unless metadata.nil?
      end

    end

  end

end