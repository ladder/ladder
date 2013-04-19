Ladder.controllers :groups do
  provides :json

  before do
    content_type :json
    params[:limit] = params[:per_page] || 25
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
    check_api_key
  end

  # List all Groups (paginated)
  get :index do
    @groups = Group.all.per_page.paginate(params)

    render 'groups', :format => :json
  end

  # Get a random Group representation
  get :random, :map => '/groups/random', :provides => [:json, :xml, :rdf] do
    @model = Group.random

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    render 'model', :format => :json
  end

  # Get an existing Group representation
  get :index, :with => :id do
    @group = Group.find(params[:id])

    render 'group', :format => :json
  end

  # Delete an existing Group
  delete :index, :with => :id do
    Group.delete(params[:id])

    body({:ok => true, :status => 200}.to_json)
  end

  # TODO: Upload a JSON hash to save as a Group

  # List related Models (paginated)
  get :models, :map => '/groups/:id/models' do
    @models = Group.find(params[:id]).models.paginate(params)

    render 'models', :format => :json
  end

end