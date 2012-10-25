Ladder.controllers :concept do

  get :index, :with => :id do
    @concept = Concept.find(params[:id])
    @querystring = session[:querystring]

    render 'concept/index'
  end
end
