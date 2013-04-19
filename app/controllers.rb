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

    # TODO: send email in background

    status 201 # resource created
    body({:api_key => tenant.api_key, :ok => true, :status => 201}.to_json)
  end

  delete :index do
    check_api_key

    # Remove existing Mongo DB and ES index
    Mongoid::Sessions.default.with(:database => Search.index_name).collections.each {|collection| collection.drop}

    index = Tire::Index.new(Search.index_name)
    index.delete if index.exists?
    index.create

    # Re-map indexes
    # TODO: ultimately this will come from an external PUT mapping

    %w[Agent Concept Resource].each do |model|
      klass = model.classify.constantize
      klass.create_indexes
      klass.put_mapping
    end

    status index.response.code
    body index.response.body
  end

end