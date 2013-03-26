Ladder.controllers :groups do
  provides :json

  before do
    content_type :json
  end

  get :index do
    @groups = Group.all # TODO: implement limit
    @opts = params.symbolize_keys.slice(:all_keys, :localize)

    render 'groups', :format => :json
  end

  get :index, :with => :id do
    @group = Group.find(params[:id])
    @opts = params.symbolize_keys.slice(:all_keys, :localize)

    render 'group', :format => :json
  end

  get :index, :map => '/groups/:id/models' do
    @models = Group.find(params[:id]).models.only(:id, :md5, :version)
    @opts = {}

    render 'models', :format => :json
  end

end