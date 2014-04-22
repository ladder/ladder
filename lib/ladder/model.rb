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
      def bind_to vocab
        embeds_one vocab.prefix, class_name: 'Ladder::Model::Embedded',
                                             cascade_callbacks: true,
                                             autobuild: true
      end

      # Return a list of vocab URIs bound to this Model
      def vocabs
        embedded_relations.map { |vocab, meta| RDF::URI.from_qname vocab }
      end

      # Take an RDF::Graph and create a Model instance from it
      def new_from_rdf(graph)
        model = self.new

        graph.each_triple do |subject, predicate, object|
          # NB: we assume the subject is the model being built
          # may consider handling subject URIs for eg. validation or implicit sameAs

          next unless vocabs.include? vocab_uri = predicate.parent # We have a valid Vocabuary

          vocab = RDF::Vocabulary.from_uri vocab_uri

          next unless vocab.predicates.include? field = predicate.qname.last # We have a valid Predicate

          embedded = model.send vocab.prefix # Ladder::Model::Embedded object
          
          if object.has_language? # track locale before setting
            locale = I18n.locale
            I18n.locale = object.language
            embedded.send("#{field}=", object.to_s)
            I18n.locale = locale
          else
            embedded.send("#{field}=", object.to_s)
          end

        end

        model
      end

    end

    # Return an RDF::Graph that can be serialized
    def to_rdf(uri)
      uri = RDF::URI.intern(uri) unless uri.is_a? RDF::URI
      graph = RDF::Graph.new

      self.class.vocabs.each do |vocab_uri|
        vocab = RDF::Vocabulary.from_uri(vocab_uri) # RDF::Vocabulary class
        embedded = self.send vocab.prefix  # Ladder::Model::Embedded object

        vocab.predicates.each do |field|
          next unless embedded[field]

          embedded[field].each do |lang, val|
            # Create language-typed literals since fields are localized
            graph << [uri, RDF::URI(vocab_uri / field), RDF::Literal(val, language: lang)]
          end
        end
      end
      
      graph
    end

  end

end