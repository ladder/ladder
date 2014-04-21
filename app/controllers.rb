L2::App.controllers  do

#  register Sinatra::LinkedData
  use Rack::LinkedData::ContentNegotiation, :standard_prefixes => true

  get :index do
    r = Resource.new ; r.dc.title = 'title' ; I18n.locale = :fr ; r.dc.title = 'francais' ; I18n.locale = :en
    r.to_rdf('http://test.uri')
  end
  
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  

end
