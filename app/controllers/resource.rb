Ladder.controllers do

  get :resource, :map => '/resource/:id', :cache => true do
    @resource = Resource.find(params[:id])

    # TODO: DRY this out somehow
    I18n.locale = params[:locale] || session[:locale]
    session[:locale] = I18n.locale if params[:locale]

    @querystring = session[:querystring]

    render 'resource'
  end

end
