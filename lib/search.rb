class Search
  attr_accessor :q, :filters, :facets, :page, :per_page, :explain, :model
  attr_reader :search, :results, :index

  def self.index
    Mongoid::Threaded.database_override || Mongoid::Sessions.default.options[:database]
  end

  def initialize(opts={})
    @index = self.class.index
    @page = 1
    @per_page = 10
    @filters = {}
    @facets = {}

    opts = opts.symbolize_keys.slice(:q, :filters, :facets, :page, :per_page, :explain)

    opts.each do |opt, value|
      self.send("#{opt}=", value)
    end
  end

  # Memoized list of populated locales in the (entire) index
  def locales
    # do a faceted search to enumerate used locales
    @locales ||= Tire.search @index do |search|
      search.query { all }
      search.size 0
      search.facet('locales') {terms 'locales', :size => 10}
    end
    @locales.results.facets['locales']['terms'].map {|locale| locale['term']}
  end

  def query
    @search = Tire::Search::Search.new(@index)

    # Set paging
    @search.from (@page.to_i - 1) * @per_page.to_i
    @search.size @per_page.to_i

    # For debugging
    @search.explain !! @explain

    # Special treatment for group, model_type, and rdf_type facets
    @search.facet('group')      {terms 'group_ids', :size => 10}
    @search.facet('type')       {terms '_type',     :size => 10}
    @search.facet('rdf_types')  {terms 'rdf_types', :size => 10}

    # set fields; prefer matches in (localized) heading, but search everywhere
    @fields = locales.map {|locale| "heading.#{locale}"} + ['_all'] + ['_id']

    # set facets
    @facets.each do |ns, fields|
      fields.each do |field|
        facet_fields = []
        locales.each do |locale|
          facet_fields << "#{ns}.#{field}.#{locale}"
        end

        @search.facet("#{ns}.#{field}") {terms facet_fields, :size => 10}
      end
    end

    # set query
    @search.query do |query|

      query.filtered do |filtered|

        filtered.query do |q|
          q.boosting(:negative_boost => 0.1) do |b|

            # query for the provided query string
            b.positive do |p|
              if @model
                p.term (@model.class.to_s.underscore + '_ids').to_sym, @model.id.to_s
              else
#              p.match @fields, @q, :operator => 'and'
                p.string @q, {:fields => @fields, :default_operator => 'and', :analyzer => 'snowball'}
              end
            end

            b.negative do
              boolean do
                # suppress results that are not document roots
                # eg. sub-concepts, items within a hierarchy, etc.
                should { string '-_exists_:parent_id' }
                should { string '-_exists_:parent_ids' }

                # suppress Concepts/Agents with no resource_ids
                should { string '-_exists_:resource_ids AND _type:concept'}
                should { string '-_exists_:resource_ids AND _type:agent'}

                # suppress Resources with no agent_ids or concept_ids
                should { string '-_exists_:concept_ids AND _type:resource'}
                should { string '-_exists_:agent_ids AND _type:resource'}
              end
            end

          end
        end

        # add filters for selected facets
        @filters.each do |ns, filter|

          if 'type' == ns
            filtered.filter :type, :value => filter['type'].first
            next
          end

          if 'rdf_types' == ns
            filter['rdf_types'].each {|v| filtered.filter :term, "rdf_types" => v}
            next
          end

          if 'group' == ns
            filter['group'].each {|v| filtered.filter :term, "group_ids" => v}
            next
          end

          filter.each do |f, arr|
            arr.each do |v|
              # FIXME: refactor me with dynamic templates
              filter_fields = []
              locales.each do |locale|
                filter_fields << {:term => {"#{ns}.#{f}.#{locale}" => v}}
              end

              filtered.filter :or, filter_fields
            end
          end
        end

      end

    end

    @results = @search.results
=begin
    unless @facets.empty?
      ids = @results.facets.map(&:last).map do |hash|
        hash['terms'].map do |term|
          term['term'] if term['term'].to_s.match(/^[0-9a-f]{24}$/)
        end
      end

      ids = ids.flatten.uniq.compact
      unless ids.empty?
        @headings = Tire.search index do |search|
          search.query { |q| q.ids ids }
          search.size ids.size
          # TODO: I think these need to be localized as above
          search.fields ['heading', 'heading_ancestors']
        end
      end
    end
=end
  end

end