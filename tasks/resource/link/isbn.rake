desc "Retrieve thumbnail URIs based on ISBN"

namespace :link do
  task :isbn, [:relink] => :environment do |t, args|

    args.with_defaults(:relink => false)

    Mongoid.unit_of_work(disable: :all) do
      # re-use http_client connection
      http_client = HTTPClient.new('http://localhost:8123')
      http_client.connect_timeout = 10
      http_client.receive_timeout = 10

      resources = Resource.any_of({:'bibo.isbn'.exists => true}, {:'dbpedia.isbn'.exists => true})
      resources = resources.without(:marc, :mods)

      # only select resources which have not already been linked
      resources = resources.dbpedia(false) unless !!args.relink
      exit if resources.empty?

      print "Linking #{resources.size} Resources using #{Parallel.processor_count ** 2} threads... "

      # spin up a lot of threads; we're heavily request-bound
      done = 0
      Parallel.each_with_index(resources, :in_threads => Parallel.processor_count ** 2) do |resource, index|
        update_hash = {}#{:dbpedia => {:thumbnail => []}}
        isbns = resource.bibo.isbn

        begin
          # get a numeric-only ISBN to look up
          isbn = isbns.pop.gsub(/[^0-9]/i, '')

          services = ["http://syndetics.com/index.aspx?isbn=#{isbn}/MC.jpg",
                      "http://covers.librarything.com/devkey/KEY/medium/isbn/#{isbn}",
                      "http://images.amazon.com/images/P/#{isbn}.01.MZZZZZZZ.jpg",
                      "http://covers.openlibrary.org/b/isbn/#{isbn}-M.jpg?default=false"]

#          Parallel.each(services, {:in_threads => services.size}) do |service_uri|
          services.each do |service_uri|
            # query the URI
            # TODO: add check using .head ; eg. if service is down
            message = http_client.head(service_uri, :follow_redirect => true) rescue next
            next unless 200 == message.status

            # FIXME: this might allow some zero-size content through?
            content_length = message.headers['Content-Length'].to_i
            next unless content_length == 0 or content_length > 100

            # build a hash here and use atomic update()
            update_hash[:dbpedia] ||= {}
            (update_hash[:dbpedia][:thumbnail] ||= []) << service_uri
          end

        end while !isbns.empty?

        # NB: this will overwrite existing values in set fields
        resource.update_attributes(update_hash) unless update_hash.empty?

        percent = ( (index.to_f / resources.size) * 100 ).to_i.round(-1)
        if percent > done
          done = percent
          print "#{done}% "
        end

      end

      puts ""
    end
  end
end