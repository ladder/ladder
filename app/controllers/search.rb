Ladder.controllers :search do

  get :index do
    if params[:q].nil?
      redirect url("/")
    else
      redirect url(:search, :index, :querystring => params[:q])
    end
  end

  get :index, :with => :querystring do

    @querystring = params[:querystring]

    @facets = {:dcterms => ['issued', 'format', 'language',       # descriptive facets
                             'creator', 'publisher',               # agent facets
                             'subject', 'spatial', 'DDC', 'LCC'] } # concept facets

    @search = Tire.search do |search|
      search.query do |query|
        query.string @querystring, :default_operator => 'AND'
      end

      # descriptive facets
      @facets.each do |ns, facet|
        facet.each do |f|
          # TODO: prepend namespace to facet somehow to avoid collisions
          search.facet(f) { terms (ns + '.' + f + '.raw').to_sym}
        end
      end
    end

    render 'search/results'
  end

end