Ladder.controllers :agent do
  provides :json, :xml, :rdf

  get :index, :with => :id do
    @model = Agent.find(params[:id])

    if :rdf == content_type or :xml == content_type
      @model.to_rdfxml(url_for current_path)
    else
      @opts = params.symbolize_keys.slice(:all_keys, :ids, :localize)
      render 'model'
    end

  end

  post :index do
    # TODO: create a new Agent using ROAR and respond
    status 200 # this is assumed
    {:success => true}.to_json
  end

end