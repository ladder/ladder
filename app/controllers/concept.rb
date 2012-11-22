Ladder.controllers :concept do

  get :index, :with => :id do
    @concept = Concept.find(params[:id])

    # TODO: DRY this out somehow
    I18n.locale = params[:locale] || session[:locale]
    session[:locale] = I18n.locale if params[:locale]

    @querystring = session[:querystring]
    @filters = params[:fi] || {}
    @page = params[:page] || 1
    @per_page = params[:pp] || 10

    search = LadderSearch::Search.new(:filters => @filters)

    search.facets = {:dcterms => %w[format language issued creator contributor publisher subject]}
    search.facet_size = 5
    search.fields = [:heading, :agent_ids, :concept_ids, :dcterms, :bibo]
    search.query = :term, :concept_ids, @concept.id

    search.search('resources', :page => @page, :per_page => @per_page)

    if search.results.empty? and search.results.total > 0 and @page.to_i > 1
      params[:page] = 1
      redirect current_path(params)
    end

    @results = search.results
    @facets = search.facets
    @headings = search.headings

    render 'concept/index'
  end
end
