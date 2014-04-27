L2::App.controllers  do

#  register Sinatra::LinkedData
  use Rack::LinkedData::ContentNegotiation, standard_prefixes: true

  get :index do
    Resource = Ladder::RDF.model name: 'Resource', vocabs: ['RDF::DC', 'RDF::MODS']
    r = Resource.new
    r.dc.title = ['title', 'another title'] ; I18n.locale = :fr ; r.dc.title = 'francais' ; I18n.locale = :en
    r.dc.alternative = ['alternate title']
    r.rdfs.comment = 'here is a comment' ; I18n.locale = :de ; r.rdfs.comment = 'deutsch' ; I18n.locale = :en
    
    r.to_rdf('http://test.uri')
  end
  
  post :index do
    body = '{"@context":{"dc":"http://purl.org/dc/terms/"},"@id":"http://test.uri","dc:title":[{"@value":"title","@language":"en"},{"@value":"another title","@language":"en"},{"@value":"francais","@language":"fr"}]}'

    hash = JSON.parse body rescue return 400 # JSON is mal-formed

    graph = RDF::Graph.new << JSON::LD::API.toRdf(hash)
    
    return 422 unless graph.valid? # JSON is well-formed, but JSON-LD is not valid RDF
    
    Resource = Ladder::RDF.model name: 'Resource', vocabs: ['RDF::DC', 'RDF::MODS']
    r = Resource.new_from_rdf(graph)
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
