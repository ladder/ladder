Ladder.controllers  do

  get :index, :provides => :json do
    # TODO: this might be a good place for ROAR / hypermedia links
    status 200 # this is assumed
    content_type 'json' # just in case

    {:name => 'Ladder',
     :ok => true,
     :status => 200,
     :version => '0.4',
     :tagline => 'Born in a library, raised on the Semantic Web'}.to_json
  end

end