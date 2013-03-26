Ladder.controllers :resources do
  provides :json

  before do
    content_type :json
  end

  get :index, :with => :id, :provides => [:json, :xml, :rdf] do
    @model = Resource.find(params[:id])
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    render 'model', :format => :json
  end

  get :files, :map => '/resources/:id/files' do
    @files = Resource.find(params[:id]).files.without(:data)

    render 'files', :format => :json
  end

  get :similar, :map => '/resources/:id/similar' do
    @similar_opts = params.symbolize_keys.slice(:amatch, :hashdiff)
    @models = Resource.find(params[:id]).similar(@similar_opts)
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    render 'models', :format => :json
  end

end