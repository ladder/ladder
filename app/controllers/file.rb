Ladder.controllers :files do
  provides :json

  before do
    content_type :json
  end

  get :index do
    @files = Model::File.without(:data).paginate(params)

    render 'files', :format => :json
  end

  get :index, :with => :id do
    @file = Model::File.without(:data).find(params[:id])

    halt 200, @file.reload.data if request.content_type == @file.content_type

    render 'file', :format => :json
  end

  post :index do
    # ensure we have content to process
    halt 400, {:error => 'No content provided', :status => 400}.to_json if 0 == request.body.length

    # create an importer for this content-type
    importer = Importer.create(request.content_type)

    halt 415, {:error => 'Unsupported content type', :status => 415, :valid => Importer.content_types}.to_json if importer.nil?

    # TODO: refactor this to use #perform_async on the class
    # NB: if request.body is large, it will ALL be serialized to sidekiq!
    @files = importer.perform(request.body, request.content_type)

    status 201 # resource created
    render 'files', :format => :json
  end

  post :index, :map => '/files/:id/map' do
    @file = Model::File.only(:id, :content_type).find(params[:id])

    # create a mapper for this content-type
    mapper = Mapper.create(@file.content_type)

    halt 501, {:error => 'Unsupported content type', :status => 501, :valid => Mapper.content_types}.to_json if mapper.nil?

    # TODO: refactor this to use #perform_async on the class
    mapper.perform(@file.id, @file.content_type)

    halt 202, {:ok => true, :status => 202}.to_json
  end

end