Ladder.controllers :concept do

  get :index, :with => :id do
    @concept = Concept.find(params[:id])
    @querystring = session[:querystring]
    @page = params[:page] || 1

    render 'concept/index'
  end
end
