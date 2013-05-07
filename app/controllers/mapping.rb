Ladder.controllers :mappings do
  provides :json

  before do
    content_type :json
    @opts = params.symbolize_keys.slice(:all_keys)
    check_api_key
  end

  # List all Mappings
  get :index do
    @mappings = Mapping.defined

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

  # Upload a mapping hash in JSON
  post :index do
    # ensure we have content to process
    halt 400, {:error => 'No content provided', :status => 400}.to_json if 0 == request.body.length

    # parse provided JSON and trap any errors
    begin
      mapping_hash = JSON.parse(request.body.read)
      mapping_hash = mapping_hash.symbolize_keys_recursive.slice(:type, :content_type, :vocabs, :agents, :concepts, :resources)

      # TODO: use Mongoid #upsert functionality
      @mapping = Mapping.create!(mapping_hash)

    rescue Exception => error
      halt 422, {:status => 422, :error => error.to_s}.to_json
    end

    status 201 # resource created

    @opts[:all_keys] = true
    render 'mapping', :format => :json
  end

end
