Ladder.controllers :search do

  get :index do
    if params[:q].nil?
      redirect url("/")
    else
      redirect url(:search, :index, :querystring => params[:q], :filters => params[:f], :page => params[:p])
    end
  end

  get :index, :with => :querystring do

    @querystring = params[:querystring] || ''
    @filters = params[:filters] || {}
    @page = params[:page] || 1          # start on the first page, duh
    @per_page = params[:per_page] || 10 # default to 10 per page

    @facets = {:dcterms => ['issued', 'format', 'language',       # descriptive facets
                             'creator', 'publisher',               # agent facets
                             'subject', 'spatial', 'DDC', 'LCC'] } # concept facets

    @results = Resource.tire.search(:page => @page, :per_page => @per_page) do |search|
      search.query do |query|
        query.filtered do |filtered|

          filtered.query do |querystring|
            querystring.string @querystring, :default_operator => 'AND'
          end

          @filters.each do |ns, filter|
            filter.each do |f, v|
              filtered.filter :term, ns.to_s + '.' + f.to_s + '.raw' => v
            end
          end

        end
      end

      # descriptive facets
      @facets.each do |ns, facet|
        facet.each do |f|
          # TODO: prepend namespace to facet somehow to avoid collisions
          search.facet(f) { terms (ns.to_s + '.' + f + '.raw').to_sym}
        end
      end
    end

    render 'search/results'
  end

end