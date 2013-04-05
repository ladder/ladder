Ladder.controllers :search do
  provides :json

  before do
    content_type :json
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
  end

  get :index do
    halt 400, {:error => 'No query provided'}.to_json
  end

  get :index, :with => :q do
    # TEMPORARY
    params[:facets] = {:dcterms => %w[format language issued creator contributor publisher subject LCSH DDC LCC]}

    @search = Search.new(params)
    @search.query

    render 'search', :format => :json
  end

end