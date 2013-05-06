Ladder.controllers :mappings do
  provides :json

  before do
    content_type :json
    @opts = params.symbolize_keys.slice(:all_keys)
    check_api_key
  end

  # List all Mappings (paginated)
  get :index do
    @mappings = Mapping.all.per_page.paginate(params)

    render 'mappings', :format => :json
  end

  # Get an existing Mapping representation
  get :index, :with => :id do
    @mapping = Mapping.find(params[:id])

    render 'mapping', :format => :json
  end

  # Delete an existing Mapping
  delete :index, :with => :id do
    Mapping.delete(params[:id])

    body({:ok => true, :status => 200}.to_json)
  end

end
