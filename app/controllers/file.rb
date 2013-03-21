Ladder.controllers :file do
  provides :json

  get :index do
    @files = Model::File.all.without(:data)

    content_type 'json'
    render 'files', :format => :json
  end
                            # NB: this list has to be maintained
  get :index, :with => :id, :provides => [:json, :xml, :marc, :mods, :rdf] do

    # Special selector instead of using #find, so we can limit fields
    @file = Model::File.where(:id => params[:id]).without(:data).first

    # Send data stream directly if that content-type is requested
    if content_type == MIME::Type.new(@file.content_type).sub_type.to_sym
      # NB: re-load the file from DB to get the :data field
      @file = Model::File.find(params[:id])

      halt 200, @file.data
    end

    content_type 'json'
    render 'file', :format => :json
  end

  post :index do
    # TODO: create a new File using POST chunked upload
    status 200 # this is assumed
    {:success => true}.to_json
  end

end