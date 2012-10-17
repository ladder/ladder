Ladder.controllers :concept do

  get :index, :with => :id do
    @concept = Concept.find(params[:id])
    render 'concept/index'
  end
end
