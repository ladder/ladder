Ladder.controllers :search do

  get :index do
    if params[:q].nil?
      render 'search/index'
    else
      redirect url(:search_index, :q => params[:q], :fi => params[:fi], :page => params[:page])
    end
  end

  get :index, :with => :q do

    @querystring = params[:q]
    @filters = params[:fi] || {}
    @page = params[:page] || 1
    @per_page = params[:pp] || 10

    @facets = {'dcterms' => ['issued', 'format', 'language',       # descriptive facets
                             'creator', 'publisher',               # agent facets
                             'subject', 'spatial', 'DDC', 'LCC'] } # concept facets

    @results = Resource.tire.search(:page => @page, :per_page => @per_page) do |search|
      search.query do |query|
        query.filtered do |filtered|

          filtered.query do |q|
            q.string @querystring, :default_operator => 'AND'
          end

          @filters.each do |ns, filter|
            filter.each do |f, arr|
              arr.each do |v|
                filtered.filter :term, ns.to_s + '.' + f.to_s + '.raw' => v
              end
            end
          end

        end
      end

      # descriptive facets
      @facets.each do |ns, facet|
        facet.each do |f|
          # TODO: prepend namespace to facet somehow to avoid collisions
          search.facet(f) { terms (ns.to_s + '.' + f + '.raw')}
        end
      end
    end

    # if we are on a page past the end, go back to the first page
    if @results.empty? and @results.total > 0 and @page.to_i > 1
      redirect url(:search, :index, :q => params[:q], :fi => params[:fi], :page => 1)
    end

    render 'search/results'
  end

end
