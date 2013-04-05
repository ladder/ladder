Ladder.controllers :groups do
  provides :json

  before do
    content_type :json
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
  end

  get :index do
    @groups = Group.all.per_page.paginate(params)

    render 'groups', :format => :json
  end

  get :index, :with => :id do
    @group = Group.find(params[:id])

    render 'group', :format => :json
  end

  get :index, :map => '/groups/:id/models' do
    @models = Group.find(params[:id]).models#.only(:id, :md5, :version)

    render 'models', :format => :json
  end

end