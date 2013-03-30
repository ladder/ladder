Ladder.controllers :files do
  provides :json

  before do
    content_type :json
  end

  get :index do
    @files = Model::File.without(:data) # TODO: implement limit

    render 'files', :format => :json
  end

  # NB: this list has to be maintained
  get :index, :with => :id do
    @file = Model::File.without(:data).find(params[:id])

    halt 200, @file.reload.data if request.content_type == @file.content_type

    render 'file', :format => :json
  end

  post :index do
    # ensure we have content to process
    halt 400, {:error => 'No content provided', :status => 400}.to_json if 0 == request.body.length

    # create an importer for this content
    importer = Importer.create(request.content_type)

    halt 415, {:error => 'Unsupported content type', :status => 415, :accepts => Importer.content_types}.to_json if importer.nil?

    # TODO: refactor this to use #perform_async on the class
    @files = importer.perform(request.body, request.content_type)

    status 201 # resource created
    render 'files', :format => :json
  end

  post :index, :map => '/files/:id/map' do
    @file = Model::File.without(:data).find(params[:id])

    # TODO: map file to a root model and associated models
    #mapper = Mapper.create(@file.content_type)

    halt 202, {:ok => true, :status => 202}.to_json
  end

end