Ladder.controllers :group do
  provides :json

  get :index do
    @groups = Group.all
    @opts = params.symbolize_keys.slice(:all_keys) # :localize is broken

    content_type 'json'
    render 'groups', :format => :json
  end

  get :index, :with => :id do
    @group = Group.find(params[:id])
    @opts = params.symbolize_keys.slice(:all_keys) # :localize is broken

    content_type 'json'
    render 'group', :format => :json
  end

  get :index, :map => '/group/:id/models' do
    @models = Group.find(params[:id]).models.only(:id, :md5, :version)
    @opts = {}

    content_type 'json'
    render 'models', :format => :json
  end

  post :index, :with => :type do
    # TODO: create a new Group using ROAR and respond
    status 200 # this is assumed
    {:success => true}.to_json
  end

  post :index, :with => [:type, :ids] do
    # TODO: create a new Group using ROAR and respond
    status 200 # this is assumed
    {:success => true}.to_json
  end

end