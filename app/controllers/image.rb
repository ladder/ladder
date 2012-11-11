Ladder.controllers :image do

  get :index, :with => :id do
    # TODO: multiple identifiers etc.
    size = params[:size] || :M

    @resource = Resource.find(params[:id])

    isbns = @resource.bibo.isbn rescue nil

    # do lookup on each ISBN in order
    # TODO: move this off to Sidekiq or something

    thumb = nil
    while !isbns.nil? and !isbns.empty? and thumb.nil?
      # get a numeric-only ISBN to look up
      isbn = isbns.pop.gsub(/[^0-9]/i, '')

      services = ["http://syndetics.com/index.aspx?isbn=#{isbn}/#{size}C.gif",
                  "http://covers.librarything.com/devkey/KEY/medium/isbn/#{isbn}",
                  "http://images.amazon.com/images/P/#{isbn}.01.MZZZZZZZ.jpg",
                  "http://covers.openlibrary.org/b/isbn/#{isbn}-#{size}.jpg"]

      Parallel.each(services, {:in_threads => services.size}) do |service|
        data = open(service) if thumb.nil?
        thumb = data if !data.nil? and data.meta['content-length'].to_i > 900
      end

    end

    unless thumb.nil?
      content_type thumb.content_type
      body thumb.read
    else
      content_type 'image/png'

      type = @resource.dcterms.format.join(' ') rescue nil
      path = File.join(PADRINO_ROOT, '/public/img/icons')
      case type
        when /video/i
          body IO.read(File.join(path, 'icon-film.png'))
        when /sound|audio/i
          body IO.read(File.join(path, 'icon-audio.png'))
        when /print/i
          body IO.read(File.join(path, 'icon-book.png'))
        when /microf/i
          body IO.read(File.join(path, 'icon-print.png'))
        when /remote/i
          body IO.read(File.join(path, 'icon-link.png'))
        when /computer/i
          body IO.read(File.join(path, 'icon-disk.png'))
        when /disc/i
          body IO.read(File.join(path, 'icon-disc.png'))
        else
          body IO.read(File.join(path, 'icon-question.png'))
      end

      halt 200
    end

  end

end