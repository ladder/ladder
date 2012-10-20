desc "Map/Re-map Resources from MODS data"

namespace :map do
  task :mods, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.mods.only(:mods)

    # only select resources which have not already been mapped
    resources = resources.dcterms(false).bibo(false).prism(false) unless args.remap

    exit if resources.empty?

    puts "Mapping #{resources.size(true)} MODS records with #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    chunks = LadderHelper::chunkify(resources)

    # suppress indexing on save
    Resource.skip_callback(:save, :after, :update_index)
    Agent.skip_callback(:save, :after, :update_index)
    Concept.skip_callback(:save, :after, :update_index)

    # NB: this benefits a bit (~10% on a 2HT CPU) from using more processes
    # eg. 2x 50%-size chunks and 2x processes; but at the cost of 2x memory
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