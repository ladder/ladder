Ladder.controllers :files do
  provides :json

  before do
    content_type :json
  end

  get :index do
    @files = Mongoid::GridFS::Fs::File.all.paginate(params)

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
    halt 415, {:error => 'Unsupported content type', :status => 415, :valid => Mapper.content_types}.to_json unless Mapper.content_types.include? request.content_type

    @file = Mongoid::GridFS.put(request.body, :content_type => request.content_type)

    status 201 # resource created
    render 'file', :format => :json
  end

  post :index, :map => '/files/:id/map' do
    @file = Mongoid::GridFS.get(params[:id])

    halt 501, {:error => 'Unsupported content type', :status => 501, :valid => Mapper.content_types}.to_json unless Mapper.content_types.include? @file.content_type

    # create a mapper for this content-type
    # TODO: refactor this to use #perform_async on the class
    mapper = Mapper.create(@file.content_type).perform(@file.id)

    status 202 # processing started
    body({:ok => true, :status => 202}.to_json)
  end

  put :index, :map => '/files/:id/compress/:compression' do
    @file = Mongoid::GridFS.get(params[:id])

    halt 415, {:error => 'Unsupported compression type', :status => 501, :valid => Compressor.compression_types}.to_json unless Compressor.compression_types.include? params[:compression].to_sym

    # (re)compress this file
    # TODO: refactor this to use #perform_async on the class
    Compressor.new.perform(@file.id, params[:compression].to_sym)

    status 202 # processing started
    body({:ok => true, :status => 202}.to_json)
  end

end