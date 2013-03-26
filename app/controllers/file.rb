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
    halt 400, {:error => 'No content provided'}.to_json if 0 == request.body.length

    # choose file import based on content type
    valid_types = []

    Model::File.descendants.each do |klass|
      if klass.content_types.include? request.content_type
        # TODO: consider moving to Sidekiq
        @files = klass.import(request.body, request.content_type)

        halt render 'files', :format => :json
      end
      valid_types += klass.content_types
    end

    halt 415, {:error => 'Unsupported content type', :accepts => valid_types}.to_json
  end

end