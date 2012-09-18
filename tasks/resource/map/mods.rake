desc "Map/Re-map Resources from MODS data"

namespace :map do
  task :mods, [:remap] => :environment do |t, args|

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
    chunks = LadderHelper::chunkify(resources)

    # disable callbacks for indexing and tree generation on save
    Resource.reset_callbacks(:save)
    Resource.reset_callbacks(:validate)
    Resource.reset_callbacks(:validation)

    Agent.reset_callbacks(:save)
    Agent.reset_callbacks(:validate)
    Agent.reset_callbacks(:validation)

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|

        # load MODS XML document
        xml = Nokogiri::XML(resource.mods).remove_namespaces!

        # map MODS elements to embedded vocabs
        resource.vocabs = LadderMapping::MODS::vocabs(xml.xpath('/mods').first)

        # NB: there might be a better way to assign embedded attributes
#        vocabs.each do |ns, vocab|
#          resource.write_attribute(ns, vocab)
#        end

        # map related resources as tree hierarchy
        relations = LadderMapping::MODS::relations(xml.xpath('/mods/relatedItem'))
        resource.assign_attributes(relations[:fields])

        if relations[:parent].nil?
          # if resource does not have a parent, assign siblings as children
          children = relations[:siblings]
        else
          children = []

          relations[:parent].save
          resource.parent = relations[:parent]
          relations[:siblings].each { |sibling| resource.parent.children << sibling }
        end

        resource.children = children + relations[:children]

        # map encoded agents to related Agent models; store relation types in vocab fields
        agents = LadderMapping::MODS::agents(xml.xpath('/mods/name'))
        resource.assign_attributes(agents[:fields])
        resource.agents << agents[:agents]

        # map encoded agents to related Agent models; store relation types in vocab fields
#        concepts = LadderMapping::MODS::concepts(xml.xpath('/mods/name'))
#        resource.assign_attributes(concepts[:fields])
#        resource.concepts << concepts[:concepts]

        resource.save
      end

      # Make sure to flush the GC when done a chunk
      GC.start
    end

  end
end