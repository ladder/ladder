Ladder.controllers :image do

  get :index, :with => :id do
    # TODO: multiple identifiers etc.
    size = params[:size] || :M

    @resource = Resource.find(params[:id])

    # get the path for thumbnails on disk
    thumbnail_path = "/system/thumbnails/resource/"
    image_path = "#{@resource.id}-#{size}.jpg"
    full_path = File.join(PADRINO_ROOT, "/public", thumbnail_path, image_path)

    # if we wound up here in error, redirect to the existing image
    redirect image_path if File.exists?(full_path)

    isbns = @resource.bibo.isbn rescue nil

    # do lookup on each ISBN in order
    # TODO: move this off to Sidekiq or something

    thumb = nil
    while !isbns.nil? and !isbns.empty? and thumb.nil?
      # get a numeric-only ISBN to look up
      isbn = isbns.pop.gsub(/[^0-9]/i, '')

      services = ["http://syndetics.com/index.aspx?isbn=#{isbn}/#{size}C.jpg",
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
      contents = thumb.read

    else
      content_type 'image/png'

      type = @resource.dcterms.format.join(' ') rescue nil
      path = File.join(PADRINO_ROOT, '/public/img/icons')
      case type
        when /video/i
          contents = IO.read(File.join(path, 'icon-film.png'))
        when /sound|audio/i
          contents = IO.read(File.join(path, 'icon-audio.png'))
        when /print/i
          contents = IO.read(File.join(path, 'icon-book.png'))
        when /microf/i
          contents = IO.read(File.join(path, 'icon-print.png'))
        when /remote/i
          contents = IO.read(File.join(path, 'icon-link.png'))
        when /computer/i
          contents = IO.read(File.join(path, 'icon-disk.png'))
        when /dis[ck]/i
          contents = IO.read(File.join(path, 'icon-disc.png'))
        else
          contents = IO.read(File.join(path, 'icon-question.png'))
      end

    end

    # save the file for subsequent requests
    Dir.mkdir(File.join(PADRINO_ROOT, "/public", thumbnail_path)) unless File.exists?(File.join(PADRINO_ROOT, "/public", thumbnail_path))

    File.open(full_path, 'wb') { |file| file.write(contents)} unless File.exists?(full_path)

    body contents
    halt 200
  end

end