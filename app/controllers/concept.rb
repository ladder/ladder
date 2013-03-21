Ladder.controllers :concept do
  provides :json

  get :index, :with => :id, :provides => [:json, :xml, :rdf] do
    @model = Concept.find(params[:id])

    if :rdf == content_type or :xml == content_type
      @model.to_rdfxml(url_for current_path)
    else
      @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
      render 'model'
    end

  end

  get :files, :map => '/concept/:id/files' do
    @files = Concept.find(params[:id]).files

    content_type 'json'
    render 'files', :format => :json
  end

  post :index do
    # TODO: create a new Concept using ROAR and respond
    status 200 # this is assumed
    {:success => true}.to_json
  end

end