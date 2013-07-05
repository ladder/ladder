Viewer.controllers do

  before do
    check_api_key

    # Extract locale from the session or querystring
    I18n.locale = params[:locale] || session[:locale]
    session[:locale] = I18n.locale if params[:locale]

    @querystring = session[:querystring]
  end

  get :index, :cache => true do
     render 'index'
  end

  get :about, :cache => true do
    render 'about'
  end

  get :resource, :map => '/resource/:id', :cache => true do
    @model = Resource.find(params[:id])

    @results = [] # TODO: this is a temporary placeholder for common model rendering

    render 'model'
  end

  get :agent, :map => '/agent/:id', :cache => true do
    @model = Agent.find(params[:id])

    search_stuff

    render 'model'
  end

  get :concept, :map => '/concept/:id', :cache => true do
    @model = Concept.find(params[:id])

    search_stuff

    render 'model'
  end

end
