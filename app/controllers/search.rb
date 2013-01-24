Ladder.controllers :search do

  get :index do
    if params[:q].nil?
      render 'index'
    else
      redirect url(:search_index, :q => params[:q], :fi => params[:fi], :page => params[:page])
    end
  end

  get :index, :with => :q do

    @querystring = params[:q]
    @filters = params[:fi] || {}
    @page = params[:page] || 1
    @per_page = params[:pp] || 25

    session[:querystring] = @querystring

    # TODO: DRY this out somehow
    I18n.locale = params[:locale] || session[:locale]
    session[:locale] = I18n.locale if params[:locale]

    # set search indexes explicitly, based on/including type filter
    indices = @filters['type'] ? @filters['type']['type'].map(&:pluralize) : %w[resources concepts agents]

    # create Tire search object
    @search = Tire::Search::Search.new(indices)
    @search.from (@page.to_i - 1) * @per_page.to_i
    @search.size @per_page.to_i

    # for debugging
    @search.explain true if params[:explain]

    # special treatment for group facet
    @search.facet('group') {terms 'group_ids', :size => 10}

    # special treatment for 'model type' and rdf type facets
    @search.facet('type') {terms '_type', :size => 10}
    @search.facet('rdf_types') {terms 'rdf_types.raw', :size => 10}

    # set fields; prefer matches in heading, but search everywhere
    @fields = ['heading', '_all']

    # set facets
    @facets = {:dcterms => %w[format language issued creator contributor publisher subject LCSH DDC LCC]}
    @facets.each do |ns, fields|
      fields.each do |field|
        @search.facet("#{ns}.#{field}") {terms "#{ns}.#{field}.raw", :size => 10}
      end
    end

    # set query
    @search.query do |query|

      query.filtered do |filtered|

        filtered.query do |q|
          q.boosting(:negative_boost => 0.1) do |b|

            # query for the provided query string
            b.positive do |p|
#              p.match @fields, @querystring, :operator => 'and'
              p.string @querystring, {:fields => @fields, :default_operator => 'and'}
            end

            b.negative do
              boolean do
                # suppress results that are not document roots
                # eg. sub-concepts, items within a hierarchy, etc.
                should { string '_exists_:parent_id' }

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

        # special treatment for groups filter
        if @filters['group']
          @filters['group']['group'].each do |v|
            filtered.filter :term, "group_ids" => v
          end
        end

        # special treatment for rdf types filter
        if @filters['rdf_types']
          @filters['rdf_types']['rdf_types'].each do |v|
            filtered.filter :term, "rdf_types.raw" => v
          end
        end

        # add filters for selected facets
        @filters.each do |ns, filter|
          next if 'group' == ns
          next if 'type' == ns
          next if 'rdf_types' == ns

          filter.each do |f, arr|
            arr.each do |v|
              filtered.filter :term, "#{ns}.#{f}.raw" => v
            end
          end
        end

      end

    end

    @results = @search.results

    if @results.empty? and @results.total > 0 and @page.to_i > 1
      params[:page] = 1
      redirect current_path(params)
    end

    if 1 == @results.size.to_i and 1 == @page.to_i
      result = @results.first
      redirect url_for(result.class.to_s.underscore.to_sym, :index, :id => result.id)
    end

    # get a list of IDs from facets and query ES for the headings to display
    # TODO: DRY this out somehow
    unless @facets.empty?
      ids = @results.facets.map(&:last).map do |hash|
        hash['terms'].map do |term|
          term['term'] if term['term'].to_s.match(/^[0-9a-f]{24}$/)
        end
      end

      ids = ids.flatten.uniq.compact
      unless ids.empty?
        @headings = Tire.search %w[resources concepts agents] do |search|
          search.query { |q| q.ids ids }
          search.size ids.size
          search.fields ['heading']
        end
      end
    end

    render 'search/results'
  end

end