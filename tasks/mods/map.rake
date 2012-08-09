desc "Map/Re-map Resources from MODS data"

namespace :mods do

  task :map, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.only(:mods).where(:mods.exists => true)
    # only select resources which have not already been mapped
    unless args.remap
      resources = resources.where(:dcterms.exists => false, \
                                  :bibo.exists => false, \
                                  :prism.exists => false)
    end
    exit if resources.empty?

    puts "Mapping #{resources.size(true)} Resources from MODS records with #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    options = {:chunk_num => 1, :per_chunk => LadderHelper::dynamic_chunk(resources)}
    chunks = []
    while chunk = resources.page(options[:chunk_num]).per(options[:per_chunk]) \
                            and chunk.size(true) > 0
      chunks << chunk
      options[:chunk_num] += 1
    end

    # queries are executed in sequence, so traverse last-to-first
    chunks.reverse!

    Parallel.each(chunks) do |chunk|
      # Make sure to reconnect after forking a new process
      Mongoid.reconnect!

      chunk.each do |resource|

        # load MODS XML document
        xml = Nokogiri::XML(resource.mods).remove_namespaces!

        vocabs = LadderMapping::MODS::map_vocabs(xml.xpath('//mods').first)

        # atomic set doesn't trigger callbacks (eg. index)
        vocabs.each do |vocab, mapped|
          resource.set(vocab, mapped.as_document)
        end
=begin
        children = LadderMapping::MODS::map_related(xml.xpath('//relatedItem'))

        children.each do |child|
          child.parentize(resource)
          child.save
        end
=end
        # TODO
#        map_concepts
#        map_agents

        resource.set(:updated_at, Time.now)
      end

    end

  end
end