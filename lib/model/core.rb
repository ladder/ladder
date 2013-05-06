module Model

  module Core

    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        include Mongoid::Document
        include Mongoid::Pagination
        include Mongoid::Tree
#      include Mongoid::Tree::Ordering
        include Mongoid::History::Trackable

        include Mongoid::Timestamps
        index({ created_at: 1 })
        index({ updated_at: 1 })

        # useful extras, see: http://mongoid.org/en/mongoid/docs/extras.html
        include Mongoid::Paranoia # NB: this is deprecated in Mongoid 4.0
        index({ deleted_at: 1 })

        # ElasticSearch integration
        # don't index group since they are only a structural construct
        unless 'Group' == name
          include Tire::Model::Search
          include Tire::Model::Callbacks
          # index name is dynamically set to the mongoid database name
          index_name(Proc.new {Search.index_name})
        end

        # Generate MD5 fingerprint for this document
        field :md5, type: Moped::BSON::Binary
        index({ md5: 1 })
        set_callback :save, :before, :generate_md5

        # Make :headings a readable class variable
        class << self; attr_reader :headings end

        # Create rdf_types field and accessor
        class << self; attr_reader :rdf_types end
        field :rdf_types

        # Include default embedded vocabularies
        embeds_one :rdfs,     class_name: 'RDFS',     cascade_callbacks: true, autobuild: true
        embeds_one :dbpedia,  class_name: 'DBpedia',  cascade_callbacks: true, autobuild: true unless 'Group' == name
      end
    end

    module ClassMethods

      # Override Mongoid #find_or_create_by
      # @see: http://rdoc.info/github/mongoid/mongoid/Mongoid/Finders
      def find_or_create_by(attrs = {})

        # use md5 fingerprint to query if a document already exists
        obj = self.new(attrs)
        query = self.where(:md5 => obj.generate_md5).hint(:md5 => 1)

        result = query.first
        return result unless result.nil?

        # otherwise create and return a new object
        obj.save
        obj
      end

      # return a random document from the collection
      def random
        self.limit(1).skip(rand(0..self.count-1)).first
      end

      def vocabs
        vocabs = {}

        embedded_relations.each do |vocab, meta|
          vocabs[vocab.to_sym] = meta.class_name.constantize
        end

        vocabs
      end

      def define_scopes
        # add scope to check for documents not in ES index
        scope :unindexed, -> do
          # only query on an existing index
          return self.queryable unless tire.index.exists?

          # NB: this will fail on empty indexes
          # get the most recent timestamp
          s = self.search {
            query { all }
            sort { by :_timestamp, 'desc' }
            fields ['_timestamp']
            size 1
          }

          # if there's a timestamp in the index, use that as the offset
          unless s.results.empty?
            timestamp = s.results.first._timestamp / 1000
            self.queryable.or(:updated_at.gte => timestamp, :created_at.gte => timestamp)
          else
            self.queryable
          end
        end
      end

      def define_mapping
        # basic object mapping for vocabs
        # TODO: put explicit mapping here when removing dynamic templates
        vocabs = self.vocabs.each_with_object({}) do |(key,val), h|
          h[key] = {:type => 'object'}
        end

        # Timestamp information
        dates = [:created_at, :deleted_at, :updated_at].each_with_object({}) {|(key,val), h| h[key] = {:type => 'date'}}

        # Hierarchy/Group information
        ids = [:parent_id, :parent_ids, :group_ids].each_with_object({}) {|(key,val), h| h[key] = {:type => 'string', :index => 'not_analyzed'}}

        # Relation information
        relations = [:agent_ids, :concept_ids, :resource_ids].each_with_object({}) {|(key,val), h| h[key] = {:type => 'string', :index => 'not_analyzed'}}

        properties = {
            # Heading is what users will correlate with most
            :heading           => {:type => 'object', :boost => 2},
            :heading_ancestors => {:type => 'object', :index => 'no'},

            # RDF class information
            :rdf_types => {:type => 'string', :index => 'not_analyzed'},

        }.merge(vocabs).merge(dates).merge(ids).merge(relations)

        # memoize mapping as a class variable
        @mapping = {:_source => { :compress => true },
                    :_timestamp => { :enabled => true, :store => 'yes' },
                    :index_analyzer => 'snowball',
                    :search_analyzer => 'snowball',
                    :properties => properties}
=begin
   # dynamic templates to store un-analyzed values for faceting
   # TODO: remove dynamic templates and use explicit facet mapping
  :dynamic_templates => [{
                             :auto_facet => {
                                 :match => '*',
                                 :match_mapping_type => '*',
                                 :mapping => {
                                     :type => 'multi_field',
                                     :fields => {
                                         '{name}' => {
                                             :type => 'string',
                                             :index => 'analyzed'
                                         },
                                         :raw => {
                                             :type => 'string',
                                             :index => 'not_analyzed'
                                         }
                                     }
                                 }
                             }
                         }]
=end
      end

      def put_mapping
        # ensure the index exists
        tire.index.create unless tire.index.exists?

        # do a PUT mapping for this index
        tire.index.mapping self.name.downcase, @mapping ||= self.define_mapping
      end

      def get_mapping
        @mapping ||= self.define_mapping
      end

      # Convert a hashed instance of the class to a stripped-down version
      #
      # @option options [ Bool ]   :all_keys Include internal tracking keys.
      # @option options [ Symbol ] :except   List of keys to recursively strip.
      # @option options [ Symbol ] :ids      One of:  :omit    Strip all ID-type values
      #                                               :resolve Turn into Hash eg. {:model => ID}
      #
      # @param [ Hash ] hash The hash to convert.
      #
      # @return [ Hash ] The converted hash.
      #
      def normalize(hash, opts={})
        # set default keys to strip
        except = opts[:except] || [:_id, :version]

        # Remove keys not declared in index mapping
        hash.delete_if { |key, value| ! self.get_mapping[:properties].keys.include? key.to_sym } unless 'Group' == self.name

        # Only keep defined vocabs by default
        hash.select! {|key| vocabs.keys.include? key.to_sym} unless opts[:all_keys]

        hash = hash.recurse do |h|
          h.symbolize_keys!

          # Strip specified keys
          h.except! *except

          # Reject nil and empty values
          h.reject! { |key, value| value.nil? or (value.kind_of? Enumerable and value.empty?) }

          # Remove non-hash, non-value keys
          h.reject! { |key, value| !value.kind_of? Enumerable } unless opts[:all_keys]

          # Sort keys
          Hash[h.sort]
        end

        # Modify Object ID references if specified
        if opts[:ids]

          hash.each do |name, vocab|
            next unless vocab.is_a? Hash

            hash[name] = vocab.recurse do |h|
              h.each do |k, values|
                next unless values.is_a? Array

                h[k] = values.map! do |value|
                  # traverse through ID-like values
                  if value.is_a? Moped::BSON::ObjectId or value.to_s.match(/^[0-9a-f]{24}$/)
                    case opts[:ids].to_sym
                      when :omit then value = nil
                      when :resolve
                        if hash[:resource_ids] and hash[:resource_ids].include? value
                          model = :resource
                        elsif hash[:agent_ids] and hash[:agent_ids].include? value
                          model = :agent
                        elsif hash[:concept_ids] and hash[:concept_ids].include? value
                          model = :concept
                        else
                          model = hash[:type] || self.name.underscore
                        end
                        value = {model.to_sym => value}
                    end
                  end

                  value
                end

                values.compact!
              end
            end
          end

          hash = hash.recurse do |h|
            # Reject nil and empty values
            h.delete_if { |key, value| value.nil? or (value.kind_of? Enumerable and value.empty?) }
          end

        end

        hash
      end

    end

    def to_normalized_hash(opts={})
      # get a hash that we can modify
      # FIXME: #to_hash breaks on Group models (undefined method in method_missing)
      opts[:localize] ? hash = self.to_hash : hash = Hash[self.as_document]

      self.class.normalize(Marshal.load(Marshal.dump(hash)), opts)
    end

    def generate_md5
      hash = self.to_normalized_hash({:ids => :omit})

      self.md5 = Moped::BSON::Binary.new(:md5, Digest::MD5.digest(hash.to_string_recursive.normalize))
    end

    # Retrieve a hash of field names and embedded vocab objects
    def vocabs
      vocabs = {}

      self.class.vocabs.keys.each do |vocab|
        vocabs[vocab] = self.send(vocab) unless self[vocab].nil?
      end

      vocabs
    end

    # Assign model vocab objects by a hash of field names
    def vocabs=(hash)
      update_attributes(hash)
    end

    def locales
      items = self.to_normalized_hash.values.map do |vocab|
        vocab.map do |field, locales|
          next unless locales.is_a? Hash
          locales.keys
        end
      end

      items.flatten.compact.uniq
    end

    def heading(opts={})
      self.class.headings.each do |heading|
        vocab = heading.keys.first
        field = heading.values.first

        unless send(vocab).nil?
          # NB: default is localized
          if opts[:delocalize]
            value = send(vocab)[field]
            value = value.symbolize_keys unless value.nil?
          else
            value = send(vocab).send(field)
          end
          return value unless value.nil?
        end
      end

      # FIXME: return 'untitled' for no heading
      opts[:delocalize] ? {I18n.locale => [I18n.t('model.untitled')]} : [I18n.t('model.untitled')]
    end

    def heading_ancestors(opts={})
      selector = parent_ids.empty? ? [self] : ancestors + [self]

      test = selector.map do |node|
        node.heading(opts)
      end

      # NB: default is localized
      if opts[:delocalize]
        test.reduce({}) do |h,pairs|
          pairs.each do |k,v|
            (h[k] ||= []) << v.first
          end
          h
        end
      else
        test.map(&:first)
      end

    end

    def amatch(model, opts={})
      options = {:hamming_similar => true,
                 :jaro_similar => true,
                 :jarowinkler_similar => true,
                 :levenshtein_similar => true,
                 :longest_subsequence_similar => true,
                 :longest_substring_similar => true,
                 :pair_distance_similar => true}

      # if we have selected specific comparisons, use those
      options = opts if opts.is_a? Hash and ! opts.empty?

      p1 = self.to_normalized_hash(options.slice(:ids)).to_string_recursive.normalize
      p2 = model.to_normalized_hash(options.slice(:ids)).to_string_recursive.normalize

      # calculate amatch score for each algorithm
      options.delete :ids
      options.each do |sim, bool|
        options[sim] = p1.send(sim, p2) if bool
      end

      options
    end

    # Search the index and return a Tire::Collection of documents that have a similarity score
    def similar(opts={:amatch => true, :hashdiff => true})
      hash = self.to_normalized_hash
      vocabs = self.vocabs
      id = self.id

      results = self.class.search do
        query do
          boolean do
            # do not include self
            must_not { term :_id, id.to_s }

            # do a structure-free search
            should { match '_all', hash.to_string_recursive.normalize(:space_char => ' ').truncate(4096, :separator => ' ', :omission => '')}

            # NB: use this as a template for recursing in normalized documents?
            hash.each do |name, vocab|
              vocab.each do |field, locales|
                locales.each do |locale, values|
                  # FIXME: temporary workaround for non-localized (dynamic) fields
                  next if values.nil?

                  values.each do |value|
                    should do
                      match "#{name}.#{field}.#{locale}", \
                            value.to_s.normalize({:space_char => ' '}).truncate(4096, :separator => ' ', :omission => '')
                    end
                  end
                end
              end
            end
          end
        end
        min_score 1
      end

      if opts[:amatch]
        # find the maximum score
        maximum = results.max_by {|result| result._score}._score unless results.empty?
      end

      if opts[:hashdiff]
        # find the number of values in the document
        hash_size = hash.values.map(&:values).flatten.map(&:values).flatten.size
      end

      # generate a score for each result
      results.each do |result|
        diffs = []

        # calculate amatch score for each result
        if opts[:amatch]
          match = self.amatch(result, opts[:amatch])
          diffs << (match.values.sum / match.size) * (result._score / maximum)
        end

        # calculate hashdiff score for each result
        if opts[:hashdiff]
          hashdiff = HashDiff.best_diff(hash, result.to_normalized_hash({:localize => true})).map(&:last).flatten.size
          diffs << 1 - ((hash_size - (hashdiff / 2)) / hash_size)
        end

        # average result of all scoring methods
        result.diff = diffs.empty? ? 0 : diffs.inject(:+) / diffs.size
      end

      # return sorted results
      results.sort {|a, b| b.diff <=> a.diff}
    end

    # more precise serialization for Tire
    def to_indexed_json
      # Use normalized copy of document
      hash = self.to_normalized_hash(:all_keys => true)

      # add heading and ancestor heading
      hash[:heading] = heading(:delocalize => true)
      hash[:heading_ancestors] = heading_ancestors(:delocalize => true)

      # add locales
      hash[:locales] = locales

      # store RDF type for faceting; property only, not qname
      hash[:rdf_types] = rdf_types.values.flatten.uniq rescue {}

      hash.to_json
    end

    # overloading for Tire after_save callback
    def update_index
      tire.update_index if self.changed?
    end

    def to_rdfxml(url)
      uri = URI.parse(url)
      interned_uri = RDF::URI.intern(RDF::URI.new(:scheme => uri.scheme, :host => uri.host, :path => uri.path))

      # get the RDF graph for each vocab
      graphs = []
      self.vocabs.each do |name, object|
        graph = object.to_rdf(interned_uri)

        graph.statements.each do |statement|
          value = statement.object.object

          # NB: this is duplicated from Model/Core/ClassMethods#normalize
          if value.is_a? Moped::BSON::ObjectId or value.to_s.match(/^[0-9a-f]{24}$/)
            # resolve IDs
            if defined? resource_ids and resource_ids.include? value
              model = :resources
            elsif defined? agent_ids and agent_ids.include? value
              model = :agents
            elsif defined? concept_ids and concept_ids.include? value
              model = :concepts
            else
              model = self.class.name.underscore
            end

#            new_statement = [statement.subject, statement.predicate, RDF::URI.intern("#{uri.scheme}://#{uri.host}/#{model}/#{statement.object}")]
            new_statement = [statement.subject, statement.predicate, RDF::URI.new(:scheme => uri.scheme, :host => uri.host, :path => "#{model}/#{statement.object}")]
            graph.delete(statement)
            graph << new_statement

          # convert URI values to actual URIs
          elsif value.is_uri?
            new_statement = [statement.subject, statement.predicate, RDF::URI.intern(value)]
            graph.delete(statement)
            graph << new_statement
          end

        end

        graphs << graph
      end

      RDF::RDFXML::Writer.buffer do |writer|
        # FIXME: this is necessary to write a rdf:Description element
        writer << RDF::Statement.new(interned_uri, RDF.type, RDF::URI.intern(''))

        # TODO: merge these somehow and process as one
        self.class.rdf_types.each do |qname, properties|
          properties.each do |property|
            writer << RDF::Statement.new(interned_uri, RDF.type, RDF::URI.from_qname(qname) / property)
          end
        end

        unless rdf_types.nil?
          rdf_types.each do |qname, properties|
            properties.each do |property|
              writer << RDF::Statement.new(interned_uri, RDF.type, RDF::URI.from_qname(qname) / property)
            end
          end
        end

        graphs.each do |graph|
          writer << graph
        end
      end

    end

  end

end