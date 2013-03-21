Ladder.controllers :file do
  provides :json

  get :index, :with => :id do
    @file = Model::File.find(params[:id])

    content_type 'json'
    render 'file', :format => :json
  end

  post :index do
    # TODO: create a new File using POST chunked upload
    status 200 # this is assumed
    {:success => true}.to_json
  end

end