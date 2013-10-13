Ladder.controllers do
  provides :json

  before do
    content_type :json
  end

  get :index do
    {:name => 'Ladder',
     :ok => true,
     :status => 200,
     :version => '0.5.0',
     :tagline => 'Born in a library, raised on the Semantic Web'}.to_json
  end

  # Create a new tenant and initialize a ladder
  post :api_key do
    email = EmailVeracity::Address.new(params[:email])

    halt 400, {:ok => false, :status => 400, :error => 'Invalid email address'}.to_json unless email.valid?

    # if the tenant already exists, just return an API key
    @tenant = Tenant.with(:database => :ladder).where({:email => params[:email]}).first_or_initialize

    halt 403, {:ok => false, :status => 403, :error => 'API key already exists'}.to_json unless @tenant.new_record?

    @tenant.save!

    # TODO: send email in background
    # TODO: move mongoid/ES stuff elsewhere?

    # Switch Mongoid to tenant's database
    Mongoid::Config.override_database("ladder_#{@tenant.database}")
    [Agent, Concept, Resource].each(&:create_indexes)

    # Create ES index
    Search.index @tenant.properties.merge(:delete => true)

    status 201 # resource created
    body({:api_key => @tenant.api_key, :ok => true, :status => 201}.to_json)
  end

  # Delete and re-initialize an entire ladder
  delete :index do
    check_api_key

    # Remove ALL existing Mongo collections
    Mongoid::Sessions.default.with(:database => Search.index_name).collections.each {|collection| collection.drop}
    [Agent, Concept, Resource].each(&:create_indexes)

    # Re-create ES index
    Search.index @tenant.properties.merge(:delete => true)

    body({:ok => true, :status => 200}.to_json)
  end

end