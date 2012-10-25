Ladder.controllers :resource do

  get :index, :with => :id do
    @resource = Resource.find(params[:id])
    @querystring = session[:querystring]

    render 'resource/index'
  end
end
