Ladder.controllers :agent do

  get :index, :with => :id do
    @agent = Agent.find(params[:id])
    @querystring = session[:querystring]
    @page = params[:page] || 1

    render 'agent/index'
  end
end
