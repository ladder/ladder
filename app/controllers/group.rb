Ladder.controllers :group do

  get :index, :with => :id, :provides => [:json, :xml] do
    @group = Group.find(params[:id])

    # if you ask for something other than xml, you get json. deal with it.
    content_type 'json' unless :xml == content_type

    @opts = params.symbolize_keys.slice(:all_keys) # localize is broken, :localize)
    render 'group'
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