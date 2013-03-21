Ladder.controllers :search do
  provides :json

  get :index, :with => :q do
    # TEMPORARY
    params[:facets] = {:dcterms => %w[format language issued creator contributor publisher subject LCSH DDC LCC]}

    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    @search = Search.new(params)
    @search.query

    content_type :json
    render 'search', :format => :json
  end

end