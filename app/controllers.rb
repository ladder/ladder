Ladder.controllers do
  provides :json

  before do
    content_type :json
  end

  get :index do
    {:name => 'Ladder',
     :ok => true,
     :status => 200,
     :version => '0.4.0',
     :tagline => 'Born in a library, raised on the Semantic Web'}.to_json
  end

  post :api_key do
    email = EmailVeracity::Address.new(params[:email])

    halt 400, {:ok => false, :status => 400, :error => 'Invalid email address'}.to_json unless email.valid?

    # if the tenant already exists, just return an API key
    tenant = Tenant.with(:database => :ladder).where({:email => params[:email]}).first_or_initialize

    halt 403, {:ok => false, :status => 403, :error => 'API key already exists'}.to_json unless tenant.new_record?

    tenant.save!

    # switch Mongoid to tenant's database
    Mongoid::Config.override_database("ladder_#{tenant.database}")
    Search.delete
    Ladder.index tenant

    # TODO: send email in background

    status 201 # resource created
    body({:api_key => tenant.api_key, :ok => true, :status => 201}.to_json)
  end

  delete :index do
    check_api_key

    index_response = Ladder.destroy @tenant

    status index_response.code
    body index_response.body
  end

end