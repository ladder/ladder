desc "Map/Re-map Resources from MODS data"

namespace :mods do

  task :map, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.mods

    # only select resources which have not already been mapped
    resources = resources.where(:dcterms.exists => false, \
                                :bibo.exists => false, \
                                :prism.exists => false) \
                                unless args.remap

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

    # disable callbacks for versioning, indexing on save
    Resource.reset_callbacks(:save)

    Parallel.each(chunks) do |chunk|
      # Make sure to reconnect after forking a new process
      Mongoid.reconnect!

      chunk.each do |resource|

        # load MODS XML document
        xml = Nokogiri::XML(resource.mods).remove_namespaces!

        # map MODS elements to embedded vocabs
        resource.update_attributes(LadderMapping::MODS::map_vocabs(xml.xpath('//mods').first))

        # map related resources as tree hierarchy
        relations = LadderMapping::MODS::map_relations(xml.xpath('//relatedItem'))

        relations[:children].map { |child| child.parent = resource }

        if relations[:parent].nil?
          # if resource does not have a parent, assign siblings as children
          relations[:siblings].map { |child| child.parent = resource }
        else
          relations[:parent].save
          resource.parent = relations[:parent]
          relations[:siblings].map { |sibling| sibling.parent = relations[:parent] }
        end

        # store relation types in vocab fields
        resource.update_attributes(relations[:fields]) unless relations[:fields].empty?

        # TODO
        #concepts = LadderMapping::MODS::map_concepts(xml.xpath('SOME_PATH'))
        #agents = LadderMapping::MODS::map_agents(xml.xpath('SOME_PATH'))
      end

    end

  end
end