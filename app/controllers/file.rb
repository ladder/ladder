Ladder.controllers :files do
  provides :json

  before do
    content_type :json
  end

  get :index do
    @files = Mongoid::GridFS.file_model.all.entries # .paginate(params)

    render 'files', :format => :json
  end

  get :index, :with => :id do
    @file = Mongoid::GridFS.get(params[:id])

    halt 200, @file.data if request.content_type == @file.content_type

    render 'file', :format => :json
  end

  post :index do
    # ensure we have content to process
    halt 400, {:error => 'No content provided', :status => 400}.to_json if 0 == request.body.length

    # ensure it is something we CAN process
    content_types = ['application/mods+xml', 'application/marc', 'application/marc+xml', 'application/marc+json']

    halt 415, {:error => 'Unsupported content type', :status => 415, :valid => content_types}.to_json unless content_types.include? request.content_type

    @file = Mongoid::GridFS.put(request.body, :content_type => request.content_type)

    status 201 # resource created
    render 'file', :format => :json
  end

  post :index, :map => '/files/:id/map' do
    @file = Mongoid::GridFS.get(params[:id])

    # create a mapper for this content-type
    mapper = Mapper.create(@file.content_type)

    halt 501, {:error => 'Unsupported content type', :status => 501, :valid => Mapper.content_types}.to_json if mapper.nil?

    # TODO: refactor this to use #perform_async on the class
    mapper.perform(@file.id, @file.content_type)

    status 202 # processing started
    body({:ok => true, :status => 202}.to_json)
  end

end