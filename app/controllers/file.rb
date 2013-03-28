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

    @files = importer.import(request.body, request.content_type)
    render 'files', :format => :json
  end

end