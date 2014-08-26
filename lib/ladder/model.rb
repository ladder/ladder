require_relative 'resource'

module Ladder

  module Model
    
    def self.test
      hash = JSON.parse File.read('models/model.jsonld')
      graph = RDF::Graph.new << JSON::LD::API.toRdf(hash)
    end

    # Take an RDF::Graph and create a Ladder::Model class from it
    def self.build_from_rdf(graph)
      object_hash = Hash.new

      graph.to_hash.each do |object_node, predicates|

        predicates.each do |subject, object|
          
          case subject.pname
          when "rdf:type"
            object.each do |type|
              next if type.pname == type.to_s # if it can't resolve a pname, we don't know this vocab

              object_hash[:types] = Array.new if object_hash[:types].nil?
              object_hash[:types] << type.pname
              
              vocab = RDF::Vocabulary.find type
              object_hash[:vocabs] = Array.new if object_hash[:vocabs].nil?
              object_hash[:vocabs] << vocab.__name__ unless object_hash[:vocabs].include? vocab.__name__
# vocab is like @context in JSON-LD
            end

          when "ladder:aliases"
            # query the graph for the node with alias definitions
            graph.query([object.first, nil, nil]).each do |subject, predicate, object|
              next if predicate.pname == predicate.to_s # if it can't resolve a pname, we don't know this vocab

              object_hash[:aliases] = Hash.new if object_hash[:aliases].nil?
              object_hash[:aliases][object.to_s.to_sym] = predicate.pname
            end
# TODO: remove the alias node from the object_node list so it's not re-processed

          when "ladder:model"
            object_hash[:name] = object.first.to_s
# TODO: Name can come from object ID
          else
            vocab = RDF::Vocabulary.find subject
            object_hash[:vocabs] = Array.new if object_hash[:vocabs].nil?
            object_hash[:vocabs] << vocab.__name__ unless object_hash[:vocabs].include? vocab.__name__
          end

        end

      end

# TODO: some way to inject [:module] = 'Name'
object_hash[:module] = 'Test'

      self.build object_hash
    end
    
    # Factory to create a Ladder::Model class
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