desc "Retrieve Linked Data from DBpedia"

namespace :link do
  task :dbpedia, [:model] => :environment do |t, args|

    # TODO: implement Concepts once we have better matching
    args.with_defaults(:model => ['Agent', 'Resource'], :relink => false)

    Mongoid.unit_of_work(disable: :all) do

      # once for each model specified
      args.model.to_a.each do |model|

        klass  = model.classify.constantize
        next if klass.empty? # nothing to index

        collection = klass.where(:'rdf_types.Vocab::DBpedia'.exists => true)
        # TODO:
        # .only(:rdf_types, :heading, :id)

        # only select documents which have not already been linked
        collection = collection.dbpedia(false) unless !!args.relink
        next if collection.empty?

        puts "Linking #{collection.size} #{model.pluralize} using #{Parallel.processor_count} processors..."

        # break collection into chunks for multi-processing
        chunks = collection.chunkify

        Parallel.each_with_index(chunks) do |chunk, index|
          # force mongoid to create a new session for each chunk
          Mongoid::Sessions.clear

          chunk.each do |item|
            # build a URI to search for a matching RDF resource
            search_uri = URI('http://lookup.dbpedia.org/api/search.asmx/KeywordSearch?')

            # TODO: loop with each heading instead of join?
            querystring = item.heading.join()

            # FIXME: this is a hack for dbpedia's order-sensitive keyword lookup
            # reverse "surname, name" for searching Agents
            querystring.gsub!(/([^,]+), ([^,^\.]+)\.?/, '\2 \1')

            # attempt to lookup based on types if defined
            types = [''] + item.rdf_types['Vocab::DBpedia'] rescue []

            begin
              search_uri.query = {'QueryClass' => types.pop, 'QueryString' => querystring}.to_query

              # query the URI, but suppress errors
              content = open(search_uri).read rescue next

              xml = Nokogiri::XML(content).remove_namespaces!
              results = xml.xpath('/ArrayOfResult/Result')

            end while (results.nil? or results.empty?) and !types.empty?

            unless results.nil? or results.empty?
              # TODO: refactor into #amatch method somewhere
              options = {:jaro_similar => true,
                         :jarowinkler_similar => true,
                         #:levenshtein_similar => true,
                         :longest_subsequence_similar => true,
                         :longest_substring_similar => true,
                         :pair_distance_similar => true}

              querystring.downcase!
              querystring.normalize!

              # if more than one result, use the closest match
              matched = nil
              results.each do |result|
                label = result.at_xpath('Label').text.downcase.normalize

                # TODO: refactor into #amatch method as above
                match = options.map {|sim, bool| querystring.send(sim, label) if bool}
                score = match.sum / match.length.to_f

                # TODO: use, eg. birth/death dates in Result/Description to improve match

                # match at 90% similarity (empirical threshold)
                if score > 0.9 then
                  matched = result
                  break
                elsif score > 0.8 then puts "#{score}: #{querystring} == #{label}" # temporary
                end
              end

              next if matched.nil?

              # TODO: add classes to document
              #  classes = matched.xpath('Classes/Class')

              resource_uri = matched.at_xpath('URI').text
              live_uri = resource_uri.sub('/dbpedia.org/', '/live.dbpedia.org/')
              rdf_uri = live_uri.sub('/resource/', '/data/')

              # query the URI, but suppress errors
              content = open(rdf_uri).read rescue next
              rdf_xml = Nokogiri::XML(content)

              # only select properties about this resource
              rdf_props = rdf_xml.at_xpath("//*[@rdf:about='#{live_uri}']")
              next if rdf_props.nil?

              rdf_props.element_children.each do |node|

                # skip properties with no namespace, since we don't know what vocab
                vocab = RDF::URI(node.namespace.href).qname.first rescue nil
                next if vocab.nil?

                # skip properties that use an unknown vocabulary
                next unless klass.vocabs.keys.include? vocab

                # skip l10n-ized properties that are not English
                # TODO: store multilingual properties
                lang = node.attribute('lang')
                next if lang and lang.to_s != 'en'

                # use resource URI if specified
                if node.text.empty?
                  # FIXME: handle resource URIs "properly"; eg. store as URI
                  case node.name
                    when 'thumbnail'
                      value = node.attribute('resource').to_s
                    else
                      value = String.new
                  end

                # FIXME: would prefer not to have to do this
                elsif node.attribute('datatype') and qname = RDF::URI(node.attribute('datatype').to_s).qname
                  # use typed data if specified, eg. XSD
                  case qname.last
                    when :date
                      value = Date.parse(node.text).to_s rescue String.new
                    when :gYear
                      value = Date.parse(node.text).to_s rescue String.new
                    else
                      value = node.text
                  end

                else
                  value = node.text
                end

                # skip if value is empty
                next if value.strip.empty?

                # @agent[:rdfs]['comment'].first - @agent[:dbpedia]['abstract'].first
                # @agent[:dbpedia]['abstract'].first - @agent[:rdfs]['comment'].first

                # TODO: build a hash here and use update() or save()
                embed = item.send(vocab).nil? ? item.send("#{vocab}=", klass.vocabs[vocab].new) : item.send(vocab)
                (embed[node.name] ||= []) << value
#                item.send(vocab).send("#{node.name}=", value)

                item.save
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