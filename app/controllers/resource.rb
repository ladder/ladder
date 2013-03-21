Ladder.controllers :resource do
  provides :json

  get :index, :with => :id, :provides => [:json, :xml, :rdf] do
    @model = Resource.find(params[:id])
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    content_type :json
    render 'model', :format => :json
  end

  get :files, :map => '/resource/:id/files' do
    @files = Resource.find(params[:id]).files

    halt 205 if @files.empty?

    content_type :json
    render 'files', :format => :json
  end

  get :similar, :map => '/resource/:id/similar' do
    @models = Resource.find(params[:id]).similar
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    halt 205 if @models.empty?

    content_type :json
    render 'models', :format => :json
  end

end