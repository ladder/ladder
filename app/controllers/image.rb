Ladder.controllers :image do

  get :index, :with => :id do
    # TODO: multiple identifiers etc.
    size = params[:size] || :M

    @resource = Resource.find(params[:id])

    isbns = @resource.bibo.isbn rescue nil

    # do lookup on each ISBN in order
    # TODO: background this somehow; Parallel.fork, Sidekiq, etc.

    while !isbns.nil? and !isbns.empty?
      # get a numeric-only ISBN to look up
      isbn = isbns.pop.gsub(/[^0-9]/i, '')

      # try syndetics
      data = open("http://syndetics.com/index.aspx?isbn=#{isbn}/#{size}C.gif")
      break if !data.nil? and data.meta['content-length'].to_i > 200

      # try librarything
      # TODO: add sizing
      data = open("http://covers.librarything.com/devkey/KEY/medium/isbn/#{isbn}")
      break if !data.nil? and data.meta['content-length'].to_i > 200

      # try amazon
      # TODO: add sizing
      data = open("http://images.amazon.com/images/P/#{isbn}.01.MZZZZZZZ.jpg")
      break if !data.nil? and data.meta['content-length'].to_i > 200

      # try openlibrary
      data = open("http://covers.openlibrary.org/b/isbn/#{isbn}-#{size}.jpg")
      break if !data.nil? and data.meta['content-length'].to_i > 900

      if isbns.empty?
        # couldn't find any covers, send an empty 1x1 GIF
        content_type 'image/gif'
        body Base64.decode64('R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==')
        halt 200
      end

    end

    unless data.nil?
      content_type data.content_type
      body data.read
    else
      # send an empty 1x1 GIF
      content_type 'image/gif'
      body Base64.decode64('R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==')
      halt 200
    end

  end

end