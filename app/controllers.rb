Ladder.controllers  do

  get "/", :cache => true do
    # TODO: DRY this out somehow
    I18n.locale = params[:locale] || session[:locale]
    session[:locale] = I18n.locale if params[:locale]

     render 'index'
  end

  get "/about", :cache => true do
    # TODO: DRY this out somehow
    I18n.locale = params[:locale] || session[:locale]
    session[:locale] = I18n.locale if params[:locale]

    render 'about'
  end

end
