require 'rdf'

module RDF

  class Vocabulary
    # create a hash of prefix-URI pairs for known vocabularies
    @@vocab_uris = self.map {|vocab| {vocab.equal?(RDF) ? :rdf : vocab.__prefix__ => vocab.to_uri.to_s}}.reduce Hash.new, :merge

    def self.predicates
      # NB: this only makes sense for defined subclasses, RDF::DC
      self.singleton_methods - RDF::Vocabulary.singleton_methods - [:properties]
    end

    def self.from_uri(uri)
      self.find {|vocab| vocab.to_uri == uri}
    end
    
    def self.prefix
      @@vocab_uris.key(self.to_uri)
    end

    def self.prefix_from_uri(uri)
      @@vocab_uris.key(uri)
    end
    
    # Return an RDF::URI for a valid Vocabulary prefix
    def self.uri_from_prefix(prefix)
      RDF::URI.intern @@vocab_uris.fetch(prefix.to_sym) rescue nil
    end

  end

end