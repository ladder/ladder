require 'rdf'
require_relative 'vocab/bibframe'
require_relative 'vocab/bibo'
require_relative 'vocab/dpla'
require_relative 'vocab/edm'
require_relative 'vocab/ladder'
require_relative 'vocab/mads'
require_relative 'vocab/marcrel'
require_relative 'vocab/mods'
require_relative 'vocab/ore'
require_relative 'vocab/premis'

module RDF

  class Vocabulary

    # create a hash of prefix-URI pairs for known vocabularies
    @@prefixes ||= self.map {|vocab| {vocab.equal?(RDF) ? :rdf : vocab.__prefix__ => vocab.to_uri.to_s}}.reduce Hash.new, :merge

    def self.prefix
      @@prefixes.key(self.to_uri)
    end

    def self.prefix_from_uri(uri)
      @@prefixes.key(uri)
    end

  end

end