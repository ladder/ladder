Ladder.controllers :concepts do
  provides :json

  before do
    content_type :json
  end

  get :index, :with => :id, :provides => [:json, :xml, :rdf] do
    @model = Concept.find(params[:id])
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    render 'model', :format => :json
  end

  get :files, :map => '/concepts/:id/files' do
    @files = Concept.find(params[:id]).files

    render 'files', :format => :json
  end

  get :similar, :map => '/concepts/:id/similar' do
    @models = Concept.find(params[:id]).similar
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    render 'models', :format => :json
  end

end