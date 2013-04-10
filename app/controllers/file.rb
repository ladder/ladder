Ladder.controllers :files do
  provides :json

  before do
    content_type :json
  end

  # List all Files (paginated)
  get :index do
    @files = Mongoid::GridFS::Fs::File.all.paginate(params)

    render 'files', :format => :json
  end

  # Get an existing File representation or data stream
  get :index, :with => :id do
    @file = Mongoid::GridFS.get(params[:id])

    halt 200, @file.data if request.content_type == @file.content_type

    render 'file', :format => :json
  end

  # Delete an existing File
  delete :index, :with => :id do
    Mongoid::GridFS.delete(params[:id])

    body({:ok => true, :status => 200}.to_json)
  end

  # Upload a data stream to save as a File; optionally queue immediately
  post :index do
    # ensure we have content to process
    halt 400, {:error => 'No content provided', :status => 400}.to_json if 0 == request.body.length

    # ensure it is something we CAN process
    halt 415, {:error => 'Unsupported content type', :status => 415, :valid => Mapper::Mapper.content_types}.to_json unless Mapper::Mapper.content_types.include? request.content_type

    attributes = {:content_type => request.content_type}
    attributes[:compression] = params[:compression].to_sym if Compressor::Compressor.compression_types.map(&:to_s).include? params[:compression]

    @file = Mongoid::GridFS.put(request.body, attributes)

    status 201 # resource created

    # map the file as well
    if params[:map]
      Mapper::Mapper.create(@file.content_type).perform_async(@file.id)

      status 202 # processing started
    end

    render 'file', :format => :json
  end

  # Queue an existing file for processing
  put :map, :map => '/files/:id/map' do
    @file = Mongoid::GridFS.get(params[:id])

    halt 501, {:error => 'Unsupported content type', :status => 501, :valid => Mapper::Mapper.content_types}.to_json unless Mapper::Mapper.content_types.include? @file.content_type

    # create a mapper and map this file to models
    Mapper::Mapper.create(@file.content_type).perform_async(@file.id)

    status 202 # processing started
    body({:ok => true, :status => 202}.to_json)
  end

  # Queue an existing file for compression
  put :compress, :map => '/files/:id/compress/:compression' do
    @file = Mongoid::GridFS.get(params[:id])

    halt 415, {:error => 'Unsupported compression type', :status => 501, :valid => Compressor::Compressor.compression_types}.to_json unless Compressor::Compressor.compression_types.map(&:to_s).include? params[:compression]

    # (re)compress this file
    Compressor::Compressor.perform_async(@file.id, params[:compression].to_sym)

    status 202 # processing started
    body({:ok => true, :status => 202}.to_json)
  end

end