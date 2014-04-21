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

    # Return an RDF::Graph that can be serialized or whatnot
    def to_rdf(uri)
      uri = RDF::URI.intern(uri) unless uri.is_a? RDF::URI
      graph = RDF::Graph.new

      self.class.vocabs.each do |vocab_uri|
        vocab = RDF::Vocabulary.from_uri(vocab_uri) # RDF::Vocabulary class
        embedded = self.send vocab_uri.qname.first  # Ladder::Model::Embedded object

        vocab.predicates.each do |field|
          next unless embedded[field]

          embedded[field].each do |lang, val|
            graph << [uri, RDF::URI(vocab_uri / field), RDF::Literal(val, language: lang)]
          end
        end
      end
      
      graph
    end

  end

end