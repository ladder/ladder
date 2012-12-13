desc "Retrieve Linked Data from DBpedia"

namespace :link do
  task :dbpedia, [:model] => :environment do |t, args|

    # TODO: implement Concepts once we have better matching
    args.with_defaults(:model => ['Resource', 'Agent'], :relink => false)

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

            # FIXME: try with each type?  each heading?
            type = item.rdf_types['Vocab::DBpedia'].first rescue next
            querystring = item.heading.first
            search_uri.query = {'QueryClass' => type, 'QueryString' => querystring}.to_query

            # query the URI, but suppress errors
            content = open(search_uri).read rescue next

            xml = Nokogiri::XML(content).remove_namespaces!
            results = xml.xpath('/ArrayOfResult/Result')

            unless results.empty?
              # use the first result for now
              # FIXME: if more than one, we can't be sure it's a match; manual intervention?
              # NB: possibly similarity match on rdfs:label
              result = results.first

              # TODO: add classes to document
              #  classes = result.xpath('Classes/Class')

              resource_uri = result.at_xpath('URI').text
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

                if node.text.empty?
                  # use resource URI if specified

                  # FIXME: handle resource URIs "properly"
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