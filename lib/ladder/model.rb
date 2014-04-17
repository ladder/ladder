module Ladder

  module Model

    def self.included(base)
      base.class_eval do
        include Mongoid::Document
      end

      # This goes at the end to allow overloading Mongoid methods
      base.extend ClassMethods
    end

    module ClassMethods

      # Creates an embedded object bound to an RDF::Vocab class
      def bind_to klass
        embeds_one klass.to_uri.qname.first, class_name: 'Ladder::Model::Embedded',
                                             cascade_callbacks: true,
                                             autobuild: true
      end

      # Return a list of vocab URIs bound to this Model
      def vocabs
        embedded_relations.map { |vocab, meta| RDF::URI.from_qname vocab }
      end

    end

    def to_rdf
      self.class.vocabs.each do |uri|
        vocab = RDF::Vocabulary.from_uri(uri)

        vocab.predicates.each do |field|
          # TODO: do some logic
        end
        
      end
    end

  end

end