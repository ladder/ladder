Ladder.controllers :search do

  get :index do
    if params[:q].nil?
      render 'search/index'
    else
      redirect url(:search_index, :q => params[:q], :fi => params[:fi], :page => params[:page])
    end
  end

  get :index, :with => :q do

    @querystring = params[:q] || session[:querystring]
    @filters = params[:fi] || {}
    @page = params[:page] || 1
    @per_page = params[:pp] || 25

    session[:querystring] = @querystring

    # TODO: these can be combined into a multi_search
    # @see: http://www.elasticsearch.org/guide/reference/api/multi-search.html
    a_search = LadderSearch::Search.new({:size => 5, :fields => [:id]})
    a_search.query = :string, @querystring, {:default_operator => 'AND'}
    a_search.search('Agent')
    @agents = a_search.results.map(&:id)

    c_search = LadderSearch::Search.new({:size => 5, :fields => [:id]})
    c_search.query = :string, @querystring, {:default_operator => 'AND'}
    c_search.search('Concept')
    @concepts = c_search.results.map(&:id)

    search = LadderSearch::Search.new(:filters => @filters)

    search.facets = {:dcterms => %w[format language issued creator contributor publisher subject DDC LCC]}
    search.fields = [:heading, :agent_ids, :concept_ids, :dcterms, :bibo]

    search.query = :boolean, {
        :should => [{ :query_string => { :query => @querystring, :default_operator => 'AND' } },
                    { :terms => { :agent_ids => @agents } },
                    { :terms => { :concept_ids => @concepts } },
        ]
    }

    # TODO: multi-index search?
    search.search('Resource', :page => @page, :per_page => @per_page)

    if search.results.empty? and search.results.total > 0 and @page.to_i > 1
      params[:page] = 1
      redirect current_path(params)
    end

    if 1 == search.results.size.to_i and 1 == @page.to_i
      redirect url_for(:resource, :index, :id => search.results.first.id)
    end

    @results = search.results
    @facets = search.facets
    @headings = search.headings

    render 'search/results'
  end

end