Ladder.controllers :resources do
  provides :json

  before do
    content_type :json
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
  end

  get :index do
    @models = Resource.all.per_page.paginate(params)

    render 'models', :format => :json
  end

  get :index, :with => :id, :provides => [:json, :xml, :rdf] do
    @model = Resource.find(params[:id])

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    render 'model', :format => :json
  end

  get :files, :map => '/resources/:id/files' do
    @files = Resource.find(params[:id]).files

    render 'files', :format => :json
  end

  get :similar, :map => '/resources/:id/similar' do
    @similar_opts = params.symbolize_keys.slice(:amatch, :hashdiff)
    @models = Resource.find(params[:id]).similar(@similar_opts)

    render 'models', :format => :json
  end

end