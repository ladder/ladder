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

    search = LadderSearch::Search.new(:filters => @filters)

    search.facets = {:dcterms => %w[format language issued creator contributor publisher subject DDC LCC]}
    search.fields = [:heading, :agent_ids, :concept_ids, :dcterms, :bibo]
    search.query = :string, @querystring, {:default_operator => 'AND'}

    # TODO: multi-index search?
    search.search(:page => @page, :per_page => @per_page)

    if search.results.empty? and search.results.total > 0 and @page.to_i > 1
      params[:page] = 1
      redirect current_path(params)
    end

    @results = search.results
    @facets = search.facets
    @headings = search.headings

    render 'search/results'
  end

end