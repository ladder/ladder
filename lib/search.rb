module LadderSearch
  class Search

    attr_accessor :query, :facets, :facet_size, :fields, :filters
    attr_reader   :results, :headings

    def initialize(opts={})
      @query      = opts[:facets] || {}
      @facets     = opts[:facets] || {}
      @facet_size = opts[:facet_size] || 10
      @fields     = opts[:fields] || []
      @filters    = opts[:filters] || []
    end

    def search(opts={})
      page = opts[:page]
      per_page = opts[:per_page]

      @results = Resource.tire.search(:page => page, :per_page => per_page) do |search|
        search.query do |query|
          query.filtered do |filtered|

            filtered.query do |q|
              q.send(*@query)
            end

            @filters.each do |ns, filter|
              filter.each do |f, arr|
                arr.each do |v|
                  filtered.filter :term, "#{ns}.#{f}.raw" => v
                end
              end
            end

          end
        end

        search.fields @fields unless @fields.empty?

        # descriptive facets
        @facets.each do |ns, facet|
          facet.each do |f|
            # TODO: prepend namespace to facet somehow to avoid collisions
            search.facet(f) do |term|
              term.terms "#{ns}.#{f}.raw", :size => @facet_size
            end
          end
        end
      end

      # get a list of IDs from facets and query ES for the headings to display
      ids = []
      @results.facets.map(&:last).each do |hash|
        hash['terms'].each do |term|
          ids << term['term'] if term['term'].to_s.match(/^[0-9a-f]{24}$/)
        end
      end
      ids.uniq!

      @headings = Tire.search do |search|
        search.query do |query|
          query.ids ids
        end
        search.size ids.size
        search.fields ['heading']
      end

    end

  end
end