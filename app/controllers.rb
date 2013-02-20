Ladder.controllers do

  before do
    # Extract locale from the session or querystring
    I18n.locale = params[:locale] || session[:locale]
    session[:locale] = I18n.locale if params[:locale]
  end

  get '/', :cache => true do
     render 'index'
  end

  get :about, :cache => true do
    render 'about'
  end

end
