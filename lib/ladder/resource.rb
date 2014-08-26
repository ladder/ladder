module Ladder

  module Resource
    # TODO: crib ActiveTriples' Configurable
    # configure base_uri: "http://oregondigital.org/resource/", rdf_label: "A label", type: RDF::ORE.Aggregation

    def self.included(base)
      base.class_eval do
        include Mongoid::Document
      end

      # This goes at the end to allow overloading Mongoid methods in ClassMethods
      base.extend ClassMethods
    end

    module ClassMethods

      # Creates an embedded object bound to an RDF::Vocab class
      def use_vocab(vocab)
        return if vocabs.include? vocab # Ensure we don't bind a vocab more than once
  
        embeds_one vocab.prefix, class_name: 'Ladder::Resource::Vocabulary',
                                             cascade_callbacks: true,
                                             autobuild: true
        yield if block_given?
      end
      
      # Creates getter/setter aliases for a (used) RDF::Vocabulary::Term
      def alias_field(name, term)
        return unless term.is_a? RDF::Vocabulary::Term   # Ensure we are using a valid term
        return unless vocabs.include? term.vocab         # Ensure we are using a bound vocab

        vocab, field = term.qname

        define_method(name) { self.send(vocab).send(field) }
        define_method("#{name}=") { |args| self.send(vocab).send("#{field}=", args) }
      end

      # Return a list of vocab URIs bound to this Model
      def vocabs
        embedded_relations.map { |prefix, meta| RDF::Vocabulary.expand_pname prefix }
      end

      # Take an RDF::Graph and create a Resource instance from it
      def new_from_rdf(graph)
        model = self.new

        graph.each_triple do |subject, predicate, object|
          # NB: we assume the subject is the model being built
          # may consider handling subject URIs for eg. validation or implicit sameAs
          vocab = RDF::Vocabulary.find predicate

          next unless vocabs.include? vocab               # We have a valid Vocabuary
          next unless vocab.properties.include? predicate # We have a valid Predicate

          embedded = model.send vocab.prefix # Ladder::Resource::Vocabulary object

          if object.has_language?
            locale = I18n.locale # track locale before setting
            I18n.locale = object.language
          end

          field = predicate.qname.last

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
        vocab = RDF::Vocabulary.find vocab_uri # RDF::Vocabulary class
        embedded = self.send vocab.prefix  # Ladder::Resource::Vocabulary object

        vocab.properties.each do |property|
          field = property.qname.last

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