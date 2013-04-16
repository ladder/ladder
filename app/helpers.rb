Ladder.helpers do
#  def current_url
#    url_for(request.path_info)
#  end

  def search(opts = {}, model = nil)
    # TEMPORARY
    params[:facets] = {:dcterms => %w[format language issued creator contributor publisher subject LCSH DDC LCC]} if params[:facets].nil?

    @search = Search::Search.new(params.merge opts)
    @search.model = model if model
    @search.query

    render 'search', :format => :json
  end
end
