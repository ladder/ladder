Ladder.controllers :agent do
  provides :json

  get :index, :with => :id, :provides => [:json, :xml, :rdf] do
    @model = Agent.find(params[:id])
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    halt 200, @model.to_rdfxml(url_for current_path) if :rdf == content_type or :xml == content_type

    content_type :json
    render 'model', :format => :json
  end

  get :files, :map => '/agent/:id/files' do
    @files = Agent.find(params[:id]).files

    halt 205 if @files.empty?

    content_type :json
    render 'files', :format => :json
  end

  get :similar, :map => '/agent/:id/similar' do
    @models = Agent.find(params[:id]).similar
    @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)

    halt 205 if @models.empty?

    content_type :json
    render 'models', :format => :json
  end

end