Ladder.controllers :group do
  provides :json

  get :index do
    @groups = Group.all
    @opts = params.symbolize_keys.slice(:all_keys) # :localize is broken

    halt 205 if @groups.empty?

    content_type :json
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
    halt 205 if @models.empty?

    content_type 'json'
    render 'models', :format => :json
  end

end