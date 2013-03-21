Ladder.controllers :group do
  provides :json

  get :index, :with => :id do
    @group = Group.find(params[:id])
    @opts = params.symbolize_keys.slice(:all_keys) # localize is broken, :localize)

    content_type 'json'
    render 'group', :format => :json
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