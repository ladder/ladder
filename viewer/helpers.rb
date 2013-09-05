Viewer.helpers do

  def check_api_key
    # send a Basic Auth header for browsers
    headers['WWW-Authenticate'] = 'Basic realm="API key required"'

    # allow passing the API key through HTTP basic auth as username
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    params[:api_key] = @auth.username if @auth.provided?

    # ensure we have an API key provided
    halt 401, {:ok => false, :status => 401, :error => 'No API key provided'}.to_json unless params[:api_key]

    # check API key
    @tenant = Tenant.with(:database => :ladder).find_by(:api_key => params[:api_key]) rescue nil

    halt 401, {:ok => false, :status => 401, :error => 'Invalid API key'}.to_json unless @tenant

    # switch Mongoid to tenant's database
    Mongoid::Config.override_database("ladder_#{@tenant.database}")
  end

end