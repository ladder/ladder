Ladder.controllers :concepts do
  provides :json

  before do
    content_type :json
    params[:limit] = params[:per_page] || 25
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
    check_api_key
  end

  # List all Concepts (paginated)
  get :index do
    @models = Concept.all.per_page.paginate(params)

    render 'models', :format => :json
  end

  # Get a random Concept representation
  get :random, :map => '/concepts/random', :provides => [:json, :xml, :rdf] do
    @model = Concept.random

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    render 'model', :format => :json
  end

  # Get an existing Concept representation
  get :index, :with => :id, :provides => [:json, :xml, :rdf] do
    @model = Concept.find(params[:id])

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    render 'model', :format => :json
  end

  # Delete an existing Concept
  delete :index, :with => :id do
    Concept.delete(params[:id])

    body({:ok => true, :status => 200}.to_json)
  end

  # TODO: Upload a JSON hash to save as a Concept

  # List related Files (paginated)
  get :files, :map => '/concepts/:id/files' do
    @files = Concept.find(params[:id]).files.paginate(params)

    render 'files', :format => :json
  end

  # List similar Concepts
  get :similar, :map => '/concepts/:id/similar' do
    @similar_opts = params.symbolize_keys.slice(:amatch, :hashdiff)
    @models = Concept.find(params[:id]).similar(@similar_opts)

    render 'models', :format => :json
  end

  # Search within related models
  get :search, :map => '/concepts/:id/search', :with => :q do
    @model = Concept.find(params[:id])

    search({}, @model)
  end

  # Reindex all Concepts
  put :reindex, :map => '/concepts/reindex' do
    Concept.delay.import

    status 202 # processing started
    body({:ok => true, :status => 202}.to_json)
  end

end