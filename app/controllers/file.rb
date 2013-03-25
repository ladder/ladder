Ladder.controllers :files do
  provides :json

  get :index do
    @files = Model::File.without(:data) # TODO: implement limit

    content_type :json
    render 'files', :format => :json
  end

  # NB: this list has to be maintained
  get :index, :with => :id, :provides => [:json, :xml, :marc, :mods, :rdf] do
    @file = Model::File.without(:data).find(params[:id])

    halt 200, @file.reload.data if content_type == MIME::Type.new(@file.content_type).sub_type.to_sym

    content_type :json
    render 'file', :format => :json
  end

  post :index do
    data = request.env['rack.input'] # StringIO

#    mime = MIME::Type.new(FileMagic.fm(:mime).buffer(file.read))
#    mime.sub_type
#    mime.simplified

    {:success => true}.to_json
  end

end