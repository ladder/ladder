#
# Class methods for all model classes within the application
#

module Model

  module Core

    module ClassMethods

      # Override Mongoid #find_or_create_by
      # @see: http://rdoc.info/github/mongoid/mongoid/Mongoid/Finders
      def find_or_create_by(attrs = {})

        # use md5 fingerprint to query if a document already exists
        obj = self.new(attrs)
        # FIXME :except is temporary
        hash = obj.to_normalized_hash({:ids => :omit, :except => [:_id, :version, :resource_ids, :concept_ids, :agent_ids, :group_ids]})
        query = self.where(:md5 => Moped::BSON::Binary.new(:md5, Digest::MD5.digest(hash.to_string_recursive.normalize)))

        result = query.first
        return result unless result.nil?

        # otherwise create and return a new object
        obj.save
        obj
      end

      def chunkify(opts = {})
        Mongoid::Criteria.new(self).chunkify(opts)
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
        ids = [:parent_id, :parent_ids, :group_ids].each_with_object({}) {|(key,val), h| h[key] = {:type => 'string'}}

        # Relation information
        relations = [:agent_ids, :concept_ids, :resource_ids].each_with_object({}) {|(key,val), h| h[key] = {:type => 'string'}}

        properties = {
            # Heading is what users will correlate with most
            :heading => {:type => 'object', :boost => 2},

            # RDF class information
            :rdf_types => { :type => 'string', :index => 'not_analyzed' },

        }.merge(vocabs).merge(dates).merge(ids).merge(relations)

        # store mapping as a class variable for future lookups
        @mapping = {:_source => { :compress => true },
                     :_timestamp => { :enabled => true, :store => 'yes' },
                     :properties => properties,
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
        }
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

      def normalize(hash, opts={})
        # set default keys to strip
        except = opts[:except] || [:_id, :version]

        # Remove keys not declared in mapping
        hash.delete_if { |key, value| ! self.get_mapping[:properties].keys.include? key.to_sym } unless 'Group' == self.name

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

          # FIXME: ids:omit should catch top-level IDs as well
          hash.select {|key| vocabs.keys.include? key}.each do |name, vocab|

            vocab.each do |field, locales|
              # special case for 'version' tracking field
              next unless locales.kind_of? Enumerable

              locales.each do |locale, values|

                if values.nil?
                  values = hash[name][field]
                  opts[:localize] = true
                end

                # traverse through ID-like values
                # TODO: refactor me somewhere reusable
                values.select {|value| value.is_a? BSON::ObjectId or value.to_s.match(/^[0-9a-f]{24}$/)}.each do |value|
                  case opts[:ids]
                    when :omit
                      # modify the value in-place
                      if opts[:localize]
                        hash[name][field].delete value
                      else
                        hash[name][field][locale].delete value
                      end

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

                      # modify the value in-place
                      if opts[:localize]
                        hash[name][field][values.index(value)] = {model.to_sym => value.to_s}
                      else
                        hash[name][field][locale][values.index(value)] = {model.to_sym => value.to_s}
                      end
                  end

                end

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

  end

end