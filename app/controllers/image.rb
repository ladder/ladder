Ladder.controllers :image do

  get :index, :with => :id do
    # TODO: multiple identifiers etc.
    size = params[:size] || :M

    @resource = Resource.find(params[:id])

    isbn = @resource.bibo.isbn.first.gsub(/[^0-9]/i, '') rescue nil
    if isbn.nil?
      # send an empty 1x1 gif.  or something.
    end

    data = open("http://covers.openlibrary.org/b/isbn/#{isbn}-#{size}.jpg")

    unless data.nil?
      content_type data.content_type
      body data.read
    end

  end

end