require 'rdf'
require_relative 'vocab/edm'
require_relative 'vocab/mads'
require_relative 'vocab/mods'

module RDF

  class Vocabulary

    # create a hash of prefix-URI pairs for known vocabularies
    @@prefixes ||= self.map {|vocab| {vocab.equal?(RDF) ? :rdf : vocab.__prefix__ => vocab.to_uri.to_s}}.reduce Hash.new, :merge

    def self.from_uri(uri)
      self.find {|vocab| vocab.to_uri == uri}
    end
    
    def self.prefix
      @@prefixes.key(self.to_uri)
    end

    def self.prefix_from_uri(uri)
      @@prefixes.key(uri)
    end
    
    # Return an RDF::URI for a valid Vocabulary prefix
    def self.uri_from_prefix(prefix)
      RDF::URI.intern @@prefixes.fetch(prefix.to_sym) rescue nil
    end

    def self.predicates
      # NB: this only makes sense for defined subclasses, RDF::DC
      self.singleton_methods - RDF::Vocabulary.singleton_methods - [:properties]
    end
    
    def self.class_properties
      props = predicates.map(&:to_s)
      props.select! { |p| p == p.camelize }
      props.reject! { |p| p == p.upcase }
      props.map(&:to_sym)
    end

  end

end