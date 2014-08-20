require_relative 'resource'

module Ladder

  module Model
    # Factory to create a Ladder::Resource class
    #
    # Required parameters:
    # :name (String)         -> the name of the model class to create
    # :module (String)       -> the name of a module to namespace classes within
    # :vocabs (Array:String) -> a list of RDF::Vocabulary classes to use
    # :types (Array:String)  -> a list of pname RDF classes to assign from given vocabs
    # :aliases (Hash)        -> (optional) a list of alias-pname key-value pairs

    def self.build(*args)
      opts = args.last || {}
      opts.symbolize_keys!

      return unless name = opts[:name] and mod = opts[:module] and vocabs = opts[:vocabs] and types = opts[:types]
      return unless mod.is_a? String and ! mod.empty?
      return unless vocabs.is_a? Array and ! vocabs.empty?
      return unless types.is_a? Array and ! types.empty?

      # If this Module is already defined, use it
      namespace = if Object.const_defined? mod.classify and mod.classify.constantize.is_a? Module
        mod.classify.constantize
      else
        Object.const_set mod.classify, Module.new
      end

      # If this Class is already modeled, return it
      return namespace.const_get name.classify if namespace.const_defined? name.classify and namespace.const_get(name.classify).is_a? Class

      klass = namespace.const_set name.classify, Class.new

      klass.class_eval do
        include Ladder::Resource
        store_in collection: 'models'

        # Associated files (eg. imported/mapped data objects) are stored in GridFS
        has_many :files, class_name: 'Mongoid::GridFS::Fs::File'
      end

      # Assign vocabs first so we know which RDF types and aliases are valid
      vocabs.each do |vocab|
        # Only allow valid RDF::Vocabulary classes
        klass.use_vocab vocab.constantize if Object.const_defined? vocab
      end
      
      if opts[:aliases].is_a? Hash and ! opts[:aliases].empty?
        opts[:aliases].each do |name, term|
          klass.alias_field(name, RDF::Vocabulary.expand_pname(term))
        end
      end
      
      valid_types = types.map do |type|
        # NB: this will throw an error if the vocabulary or tem aren't defined
        term = RDF::Vocabulary.expand_pname type

        next unless term.is_a? RDF::Vocabulary::Term
        next unless klass.vocabs.include? term.vocab # check type against vocabs for this model

        # use CamelCase convention to ensure this is a Class property
        next unless term.qname.last.to_s.camelize == term.qname.last.to_s and term.qname.last.to_s.upcase != term.qname.last.to_s
        
        type
      end

      klass.class_eval do
        # Array of rdf:type values for Classes
        field :types, type: Array, default: valid_types.uniq.compact
      end

      klass
    end

  end

end