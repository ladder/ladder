desc "Retrieve thumbnail URIs based on ISBN"

namespace :link do
  task :isbn, [:relink] => :environment do |t, args|

    args.with_defaults(:relink => false)

    Mongoid.unit_of_work(disable: :all) do
      # re-use http_client connection
      http_client = HTTPClient.new
      http_client.connect_timeout = 10
      http_client.receive_timeout = 10

      # TODO: use ISBNs from dbpedia? (may not be the same edition/version)
      #resources = Resource.any_of({:'bibo.isbn'.exists => true}, {:'prism.isbn'.exists => true}, {:'dbpedia.isbn'.exists => true})
      resources = Resource.where(:'prism.isbn'.exists => true)
      resources = resources.without(:marc, :mods)

      # only select resources which have not already been linked
      resources = resources.where(:dbpedia.exists => false) unless !!args.relink
      exit if resources.empty?

      puts "Linking #{resources.size} Resources using #{Parallel.processor_count} processors... "

      # break collection into chunks for multi-processing
      chunks = resources.chunkify

      Parallel.each_with_index(chunks) do |chunk, index|
        # force mongoid to create a new session for each chunk
        Mongoid::Sessions.clear

        # spin up a lot of threads; we're heavily request-bound
        Parallel.each(chunk, :in_threads => Parallel.processor_count) do |resource|
          isbns = resource.prism.isbn.dup

          while !isbns.empty?
            # get a numeric-only ISBN to look up
            isbn = isbns.pop.gsub(/[^0-9]/i, '')

            services = ["http://syndetics.com/index.aspx?isbn=#{isbn}/MC.jpg",
                        "http://covers.librarything.com/devkey/KEY/medium/isbn/#{isbn}",
                        "http://images.amazon.com/images/P/#{isbn}.01.MZZZZZZZ.jpg",
                        "http://covers.openlibrary.org/b/isbn/#{isbn}-M.jpg?default=false"]

            services.each do |service_uri|
              # query the URI
              # TODO: add check using .head ; eg. if service is down
              message = http_client.head(service_uri, :follow_redirect => true) rescue next
              next unless 200 == message.status

              # see if a full GET request returns a content length
              content_length = message.headers['Content-Length'].to_i

              if 0 == content_length
                message = http_client.get(service_uri, :follow_redirect => true, 'Range' => 'bytes=0-150') rescue next
                content_length = message.headers['Content-Length'].to_i || message.content.length
              end
              next unless content_length > 100

              # set the field value in-place
              # TODO: ensure we don't add duplicate values
              (resource.dbpedia[:thumbnail] ||= []) << service_uri
            end

          end

          resource.save
        end

        puts "Finished chunk: #{(index+1)}/#{chunks.size}"

        # disconnect the session so we don't leave it orphaned
        Mongoid::Sessions.default.disconnect

        # Make sure to flush the GC when done a chunk
        GC.start
      end

    end
  end
end