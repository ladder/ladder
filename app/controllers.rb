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

    tenant = Tenant.with(:database => :ladder).find_or_create_by({:email => params[:email], :database => params[:email].parameterize})

    # TODO: initialize database & index
    # TODO: send email in background

    status 201 # resource created
    body({:api_key => tenant.api_key, :ok => true, :status => 201}.to_json)
  end

  delete :index do
    check_api_key

    index_response = Ladder.destroy

    status index_response.code
    body index_response.body
  end

end