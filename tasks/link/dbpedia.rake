desc "Retrieve Linked Data from DBpedia"

namespace :link do
  task :dbpedia, [:model, :relink] => :environment do |t, args|

    args.with_defaults(:model => ['Concept', 'Resource', 'Agent'], :relink => false)

    Mongoid.unit_of_work(disable: :all) do
      # re-use http_client connection
      http_client = HTTPClient.new
      http_client.connect_timeout = 10
      http_client.receive_timeout = 10

      # once for each model specified
      args.model.to_a.each do |model|

        klass  = model.classify.constantize
        next if klass.empty? # nothing to link

        collection = klass # NB: this seems ... naked

        # only select documents which have not already been linked
        collection = collection.where(:dbpedia.exists => false) unless !!args.relink
        next if collection.empty?

        puts "Linking #{collection.size} #{model.pluralize} using #{Parallel.processor_count} processors... "

        # break collection into chunks for multi-processing
        chunks = collection.chunkify

        #######
        # build a URI to search for a matching RDF resource
        search_uri = 'http://lookup.dbpedia.org/api/search.asmx/KeywordSearch?'

        # TODO: refactor into #amatch method somewhere
        options = {:jaro_similar => true,
                   :jarowinkler_similar => true,
                   #:levenshtein_similar => true,
                   :longest_subsequence_similar => true,
                   :longest_substring_similar => true,
                   :pair_distance_similar => true}
        #######

        Parallel.each_with_index(chunks) do |chunk, index|
          # force mongoid to create a new session for each chunk
          Mongoid::Sessions.clear

          # spin up a lot of threads; we're heavily request-bound
          Parallel.each(chunk, :in_threads => Parallel.processor_count) do |item|

            # TODO: loop with each heading instead of join?
            # TODO: handle concept LCSH hierarchy
            # TODO: handle 'untitled' better in Model#heading
            if item.is_a? Concept
              querystring = item.heading_ancestors.join(' ')
            else
              querystring = item.heading.join()
            end

            # FIXME: this is a hack for dbpedia's order-sensitive keyword lookup
            # reverse "surname, name" for searching Agents
            querystring.gsub!(/([^,]+), ([^,^\.]+)\.?/, '\2 \1')

            next if 'untitled' == querystring

            # attempt to lookup based on types in decreasing order of specificity
            rdf_types = klass.rdf_types[:dbpedia]
            rdf_types = rdf_types + item.rdf_types.symbolize_keys[:dbpedia] unless item.rdf_types.nil?
            types = rdf_types.uniq.reverse

            while !types.empty?
              # query the URI
              # TODO: add check using .head ; eg. if service is down
              message = http_client.get(search_uri, {:QueryClass => types.pop, :QueryString => querystring}) rescue next
              next unless 200 == message.status

              xml = Nokogiri::XML(message.content).remove_namespaces!
              results = xml.xpath('/ArrayOfResult/Result')

              # if we have results, see if any match
              unless results.nil? or results.empty?

                results.each do |result|
                  # normalize label and heading (querystring) for similarity matching
                  label = result.at_xpath('Label').text.downcase.normalize

                  querystring.downcase!
                  querystring.normalize!

                  # TODO: refactor into #amatch method as above?
                  # TODO: use, eg. birth/death dates in Result/Description to improve match
                  match = options.map {|sim, bool| querystring.send(sim, label) if bool}
                  score = match.sum / match.length.to_f

                  # TODO: pass through ability to set a threshold here
                  if score >= 0.9 then

                    # we have a heading match, check class intersection
                    classes = result.xpath('Classes/Class/URI').map {|rdf_class| RDF::URI.intern(rdf_class.text).qname}
                    classes = classes.select {|vocab, name| :dbpedia == vocab}.map {|pair| pair.last}

                    # if classes intersect, consider it a match
                    unless (classes & rdf_types).empty?

                      # TODO: MOAR REFACTOR
                      resource_uri = result.at_xpath('URI').text
                      live_uri = resource_uri#.sub('/dbpedia.org/', '/live.dbpedia.org/')
                      rdf_uri = live_uri.sub('/resource/', '/data/')

                      # query the URI
                      # TODO: add check using .head ; eg. if service is down
                      message = http_client.get(rdf_uri) rescue next
                      next unless 200 == message.status

                      rdf_xml = Nokogiri::XML(message.content)

                      # only select properties about this resource
                      rdf_props = rdf_xml.at_xpath("//*[@rdf:about='#{live_uri}']")
                      next if rdf_props.nil?

                      rdf_props.element_children.each do |node|

                        # skip properties with no namespace, since we don't know what vocab to use
                        vocab = ignore_nil {RDF::URI.intern(node.namespace.href).qname.first}
                        next if vocab.nil?

                        # skip properties that use an unknown vocabulary
                        next unless klass.vocabs.keys.include? vocab or :rdf == vocab

                        # skip l10n-ized properties that are not English (for now)
                        # TODO: store multilingual properties
                        lang = node.attribute('lang')
                        next unless 'en' == lang.to_s or lang.nil?

                        # use resource URI if specified
                        if node.text.empty?

                          # FIXME: handle resource URIs "properly"; eg. store as URI type
                          case node.name
                            when 'type'
                              # special case to add RDF types directly
                              resource_uri = RDF::URI.intern(node.attribute('resource')).qname

                              if resource_uri and klass.vocabs.keys.include? resource_uri.first
                                (item.rdf_types['dbpedia'] ||= []) << resource_uri.last #unless rdf_types.include? resource_uri
                              end
                              value = ''

                            when 'thumbnail'
                              # TODO: make more sexy
                              thumb_uri = node.attribute('resource').to_s
                              thumb_message = http_client.head(thumb_uri, :follow_redirect => true)

                              if 200 != thumb_message.status
                                thumb_uri.sub!('/commons/', '/en/')
                                thumb_message = http_client.head(thumb_uri, :follow_redirect => true)
                              end

                              if 200 == thumb_message.status
                                value = thumb_uri
                              else
                                value = ''
                              end

                            else
                              value = ''
                          end
                        else
                          value = node.text
                        end

                        # skip if value is empty
                        next if value.strip.empty?

                        # set the field value in-place
                        # FIXME: this will overwrite existing values
                        field = node.name.to_sym
                        item.send(vocab)[field] = [value]
                      end

                      # save RDF data for later processing
                      item.files << Model::File.new(:data => message.content, :content_type => 'application/rdf+xml')

                      # we're done here
                      item.save
                      types = []
                    end
                  end
                end
              end
            end

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
end