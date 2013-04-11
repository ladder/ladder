Ladder.controllers do
  provides :json

  get :index do
    # TODO: this might be a good place for ROAR / hypermedia links

    content_type :json
    {:name => 'Ladder',
     :ok => true,
     :status => 200,
     :version => '0.4.0',
     :tagline => 'Born in a library, raised on the Semantic Web'}.to_json
  end

  delete :index do
    # Remove existing Mongo DB and ES index
    Mongoid::Sessions.default.with(:database => Search.index).collections.each {|collection| collection.drop}

    index = Tire::Index.new(Search.index)
    index.delete if index.exists?

    # Re-map indexes
    # TODO: ultimately this will come from an external PUT mapping

    %w[Agent Concept Resource].each do |model|
      klass = model.classify.constantize
      klass.create_indexes
      klass.put_mapping
    end

    content_type :json
    status index.response.code
    body index.response.body
  end

end