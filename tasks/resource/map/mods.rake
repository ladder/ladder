desc "Map/Re-map Resources from MODS data"

namespace :map do
  task :mods, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.mods.only(:mods)

    # only select resources which have not already been mapped
    resources = resources.dcterms(false).bibo(false).prism(false) unless args.remap

    exit if resources.empty?

    puts "Mapping #{resources.size} MODS records with #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    # only use chunks of 1000 to avoid mongo cursor timeouts for large sets
    chunks = LadderHelper::chunkify(resources, {:per_chunk => 1000})

    # suppress indexing on save
    Resource.skip_callback(:save, :after, :update_index)
    Agent.skip_callback(:save, :after, :update_index)
    Concept.skip_callback(:save, :after, :update_index)

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|
        # load MODS XML document
        xml = Nokogiri::XML(resource.mods).remove_namespaces!

        # instantiate mapping object
        mapping = LadderMapping::MODS.new
        mapping.map(resource, xml.at_xpath('/mods'))
      end

      # Make sure to flush the GC when done a chunk
      GC.start
    end

  end
end