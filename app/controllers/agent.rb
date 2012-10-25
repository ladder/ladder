Ladder.controllers :agent do

  get :index, :with => :id do
    @agent = Agent.find(params[:id])
    @querystring = session[:querystring]

    render 'agent/index'
  end
end
