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

      # Return a list of vocab QNames bound to this Model
      def vocabs
        embedded_relations.map do |vocab, meta|
          vocab.to_sym
        end
      end

    end

  end

end