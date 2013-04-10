Ladder.controllers :groups do
  provides :json

  before do
    content_type :json
    params[:limit] = params[:per_page] || 25
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
  end

  # List all Groups (paginated)
  get :index do
    @groups = Group.all.per_page.paginate(params)

    render 'groups', :format => :json
  end

  # Get an existing Group representation
  get :index, :with => :id do
    @group = Group.find(params[:id])

    render 'group', :format => :json
  end

  # List related Models (paginated)
  get :models, :map => '/groups/:id/models' do
    @models = Group.find(params[:id]).models.paginate(params)

    render 'models', :format => :json
  end

end