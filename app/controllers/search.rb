Ladder.controllers :search do
  provides :json

  before do
    content_type :json
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
    check_api_key
  end

  get :index do
    halt 400, {:error => 'No query provided'}.to_json
  end

  get :index, :with => :q do
    search
  end

  get :resources, :with => :q do
    search({'filters' => { 'type' => {'type' => ['resource']}}}) # FIXME: allow symbols
  end

  get :concepts, :with => :q do
    search({'filters' => { 'type' => {'type' => ['concept']}}}) # FIXME: allow symbols
  end

  get :agents, :with => :q do
    search({'filters' => { 'type' => {'type' => ['agent']}}}) # FIXME: allow symbols
  end

  # Delete entire ES index
  delete :index do
    # Delete ES index
    index = Tire::Index.new(Search.index_name)
    index.delete if index.exists?
    index.create

    status index.response.code
    body index.response.body
  end

  # Reindex all models
  put :reindex do
    %w[Agent Concept Resource].each do |model|
      model.constantize.delay.import
    end

    status 202 # processing started
    body({:ok => true, :status => 202}.to_json)
  end

end