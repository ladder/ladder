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
      def use_vocab(vocab)
        embeds_one vocab.prefix, class_name: 'Ladder::Model::Embedded',
                                             cascade_callbacks: true,
                                             autobuild: true
      end

      # Return a list of vocab URIs bound to this Model
      def vocabs
        embedded_relations.map { |prefix, meta| RDF::Vocabulary.uri_from_prefix prefix }
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

          if object.has_language?
            locale = I18n.locale # track locale before setting
            I18n.locale = object.language
          end

          if embedded.send(field).kind_of? Enumerable
            embedded.send(field) << object.to_s
          else
            embedded.send("#{field}=", Array(object.to_s))
          end

          I18n.locale = locale if object.has_language? # reset locale
        end

        model
      end

    end

    # Return an RDF::Graph that can be serialized
    # Takes a base URI 
    def to_rdf(uri)
      uri = RDF::URI.intern(uri) unless uri.is_a? RDF::URI
      graph = RDF::Graph.new

      self.class.vocabs.each do |vocab_uri|
        vocab = RDF::Vocabulary.from_uri(vocab_uri) # RDF::Vocabulary class
        embedded = self.send vocab.prefix  # Ladder::Model::Embedded object

        vocab.predicates.each do |field|
          next unless embedded[field]

          # Create language-typed literals since fields are localized
          embedded[field].each do |lang, val|
            if val.kind_of? Enumerable
              val.each {|value| graph << [uri / self.id, vocab_uri / field, RDF::Literal(value, language: lang)] }
            else
              graph << [uri / self.id, vocab_uri / field, RDF::Literal(val, language: lang)]
            end
          end
        end
      end
      
      graph
    end

  end

end