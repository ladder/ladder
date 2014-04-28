require_relative 'model'

module Ladder

  class RDF
    include Ladder::Model
    use_vocab ::RDF::RDFS
    
    # Create a Model class bound to specific vocabs
    # Required parameters:
    # :name (String)  -> the name of the model class to create
    # :vocabs (Array:String) -> a list of RDF::Vocabulary classes to use

    def self.model(*args)
      opts = args.last || {}

      return unless name = opts[:name] and vocabs = opts[:vocabs]
      return unless vocabs.is_a? Array

      # If this class is already a defined constant, return it
      return klass = name.classify.constantize if Object.const_defined? name.classify

      klass = Object.const_set name.classify, Class.new(self)

      vocabs.each do |vocab|
        # Only allow valid RDF::Vocabulary classes
        klass.use_vocab vocab.constantize if Object.const_defined? vocab
      end

      klass
    end

  end

end