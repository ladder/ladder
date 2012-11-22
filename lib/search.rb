module LadderSearch
  class Search

    attr_accessor :query, :size, :facets, :facet_size, :fields, :filters
    attr_reader   :results, :headings

    def initialize(opts={})
      @query      = opts[:facets] || {}
      @size       = opts[:size] || nil
      @facets     = opts[:facets] || {}
      @facet_size = opts[:facet_size] || 10
      @fields     = opts[:fields] || []
      @filters    = opts[:filters] || []
    end

    def search(model, opts={})
      # NB: we have to calculate our own pages because this isn't a model search
      from = (opts[:page].to_i - 1) * opts[:per_page].to_i
      size = opts[:per_page].to_i

      @search = Tire.search(model, :from => from, :size => size) do |search|
#        search.explain true

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

            # TODO: add filter to remove Concepts (Agents?) with no resource_ids
#            filtered.filter :bool, {
#                :must => [{ :type => { :value => 'concept' } },
#                              { :exists => { :field => 'resource_ids' } }
#                ]
#            }

          end
        end

        search.size @size unless @size.nil?
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
      @results = @search.results

      # get a list of IDs from facets and query ES for the headings to display
      unless @facets.empty?
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
end