#
# Instance methods for all model classes within the application
#

module Model

  module Core

    def self.included(base)
      base.send :include, Mongoid::Document

      # useful extras, see: http://mongoid.org/en/mongoid/docs/extras.html
      base.send :include, Mongoid::Paranoia # soft deletes
      base.send :index, { deleted_at: 1 }#, { sparse: true }

      base.send :include, Mongoid::Timestamps
      base.send :index, { created_at: 1 }#, { sparse: true }
      base.send :index, { updated_at: 1 }#, { sparse: true }

      base.send :include, Mongoid::Tree
      #base.send :include, Mongoid::Tree::Ordering
      base.send :include, Mongoid::History::Trackable

      # Pagination
      base.send :include, Kaminari::MongoidExtension::Criteria
      base.send :include, Kaminari::MongoidExtension::Document

      # ElasticSearch integration
      # don't index group since they are only a structural construct
      unless 'Group' == base.name
        base.send :include, Tire::Model::Search
        base.send :include, Tire::Model::Callbacks2 # local patched version
        base.send :index_name, base.database_name
      end

      # Generate MD5 fingerprint for this document
      base.send :field, :md5, type: Moped::BSON::Binary
      base.send :index, { md5: 1 }#, { unique: true }
      base.send :set_callback, :save, :before, :generate_md5

      # Make :headings a readable class variable
      base.send :class_eval, %(class << self; attr_reader :headings end)

      # Create rdf_types field and accessor
      base.send :class_eval, %(class << self; attr_reader :rdf_types end)
      base.send :field, :rdf_types

      # Include default embedded vocabularies
      base.send :embeds_one, :dbpedia,  class_name: 'DBpedia',  cascade_callbacks: true, autobuild: true
      base.send :embeds_one, :rdfs,     class_name: 'RDFS',     cascade_callbacks: true, autobuild: true

      # add useful class methods
      # NB: This has to be at the end to monkey-patch Tire, Kaminari, etc.
      base.extend ClassMethods
    end

    def to_normalized_hash(opts={})
      # get a hash that we can modify
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
      test = ancestors_and_self.map do |node|
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
    def similar(opts={})
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

      # find the maximum score
      maximum = results.max_by {|result| result._score}._score unless results.empty?

      if opts[:amatch]
        # calculate amatch score for each result
        results.each do |result|
          match = self.amatch(result, opts[:amatch])
          result.diff = (match.values.sum / match.size) * (result._score / maximum)
        end
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

    def to_rdfxml(url)
      uri = URI.parse(url)

      # get the RDF graph for each vocab
      graphs = []
      self.vocabs.each do |name, object|
        graph = object.to_rdf(RDF::URI.intern(url))

        graph.statements.each do |statement|
          value = statement.object.object

          # NB: this is duplicated from Model/Core/ClassMethods#normalize
          if value.is_a? BSON::ObjectId or value.to_s.match(/^[0-9a-f]{24}$/)
            # resolve IDs
            if defined? resource_ids and resource_ids.include? value
              model = :resource
            elsif defined? agent_ids and agent_ids.include? value
              model = :agent
            elsif defined? concept_ids and concept_ids.include? value
              model = :concept
            else
              model = self.class.name.underscore
            end

            new_statement = [statement.subject, statement.predicate, RDF::URI.intern("#{uri.scheme}://#{uri.host}/#{model}/#{statement.object}")]
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
        writer << RDF::Statement.new(RDF::URI.intern(url), RDF.type, RDF::URI.intern(''))

        # TODO: merge these somehow and process as one
        self.class.rdf_types.each do |qname, properties|
          properties.each do |property|
            writer << RDF::Statement.new(RDF::URI.intern(url), RDF.type, RDF::URI.from_qname(qname) / property)
          end
        end

        unless rdf_types.nil?
          rdf_types.each do |qname, properties|
            properties.each do |property|
              writer << RDF::Statement.new(RDF::URI.intern(url), RDF.type, RDF::URI.from_qname(qname) / property)
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