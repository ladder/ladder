Ladder.controllers :search do

  get :index do
    if params[:q].nil?
      render 'search/index'
    else
      redirect url(:search_index, :q => params[:q], :fi => params[:fi], :page => params[:page])
    end
  end

  get :index, :with => :q do

    @querystring = params[:q] || session[:querystring]
    @filters = params[:fi] || {}
    @page = params[:page] || 1
    @per_page = params[:pp] || 25

    session[:querystring] = @querystring

    @facets = {:dcterms => %w[format language issued creator contributor publisher subject DDC LCC]}

    @fields = [:heading, :agent_ids, :concept_ids, :dcterms]
    # TODO: filter nested fields?
    # ['dcterms.issued', 'dcterms.format', 'dcterms.language', 'dcterms.creator']

    # TODO: multi-index search?
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

      search.fields @fields

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

    # get a list of IDs from facets and query ES for the headings to display
    @results.facets.map(&:last).each do |hash|
      hash['terms'].each do |term|
        (@ids ||= []) << term['term'] if term['term'].to_s.match(/^[0-9a-f]{24}$/)
      end
    end
    @ids.uniq!

    @headings = Tire.search do |search|
      search.query do |query|
        query.ids @ids
      end
      search.size @ids.size
      search.fields ['heading']
    end

    render 'search/results'
  end

end
