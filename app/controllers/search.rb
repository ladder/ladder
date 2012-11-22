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

    search = LadderSearch::Search.new(:filters => @filters)
    search.facets = {:dcterms => %w[format language issued creator contributor publisher subject DDC LCC]}
    search.query = :text, :_all, @querystring, {:operator => 'AND' }
    search.search('*', :page => @page, :per_page => @per_page)

    if search.results.empty? and search.results.total > 0 and @page.to_i > 1
      params[:page] = 1
      redirect current_path(params)
    end

    if 1 == search.results.size.to_i and 1 == @page.to_i
      result = search.results.first
      redirect url_for(result.class.to_s.underscore.to_sym, :index, :id => result.id)
    end

    @results = search.results
    @facets = search.facets
    @headings = search.headings

    render 'search/results'
  end

end