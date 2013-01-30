Ladder.controllers :concept do

  get :index, :with => :id do
    @concept = Concept.find(params[:id])

    # TODO: DRY this out somehow
    I18n.locale = params[:locale] || session[:locale]
    session[:locale] = I18n.locale if params[:locale]

    @querystring = session[:querystring]
    @filters = params[:fi] || {}
    @page = params[:page] || 1
    @per_page = params[:pp] || 10


    # set facets
    @facets = {:dcterms => %w[format language issued creator contributor publisher subject]}

    # create Tire search object
    @results = Resource.search(:page => @page, :per_page => @per_page) do |s|

      s.query do |query|

        query.filtered do |filtered|
          filtered.query do |q|
            q.term :concept_ids, @concept.id.to_s
          end

          @filters.each do |ns, filter|
            filter.each do |f, arr|
              arr.each do |v|
                filtered.filter :term, "#{ns}.#{f}.raw" => v
              end
            end
          end
        end

      end

      @facets.each do |ns, fields|
        fields.each do |field|
          s.facet("#{ns}.#{field}") {terms "#{ns}.#{field}.raw", :size => 10}
        end
      end

    end

    if @results.empty? and @results.total > 0 and @page.to_i > 1
      params[:page] = 1
      redirect current_path(params)
    end

    # get a list of IDs from facets and query ES for the headings to display
    # TODO: DRY this out somehow
    unless @facets.empty?
      ids = @results.facets.map(&:last).map do |hash|
        hash['terms'].map do |term|
          term['term'] if term['term'].to_s.match(/^[0-9a-f]{24}$/)
        end
      end

      ids = ids.flatten.uniq.compact
      unless ids.empty?
        @headings = Tire.search Tire::Index.default do |search|
          search.query { |q| q.ids ids }
          search.size ids.size
          search.fields ['heading']
        end
      end
    end

    render 'concept'
  end
end
