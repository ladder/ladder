Ladder.controllers :concept do
  provides :json

  get :index, :with => :id, :provides => [:json, :xml, :rdf] do
    @model = Concept.find(params[:id])
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    content_type :json
    render 'model', :format => :json
  end

  get :files, :map => '/concept/:id/files' do
    @files = Concept.find(params[:id]).files

    content_type :json
    render 'files', :format => :json
  end

  get :similar, :map => '/concept/:id/similar' do
    @models = Concept.find(params[:id]).similar
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    content_type :json
    render 'models', :format => :json
  end

end