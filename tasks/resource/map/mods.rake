desc "Map/Re-map Resources from MODS data"

namespace :map do
  task :mods, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.mods.only(:mods)

    # only select resources which have not already been mapped
    resources = resources.dcterms(false).bibo(false).prism(false) unless args.remap

    exit if resources.empty?

    puts "Mapping #{resources.size(true)} Resources from MODS records with #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    chunks = LadderHelper::chunkify(resources)

    # instantiate mapping object
    mapping = LadderMapping::MODS.new

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|
        mapping.map(resource)
        mapping.save
        
        # ensure similarity searches are fresh
        resource.tire.index.refresh
      end

      # Make sure to flush the GC when done a chunk
      GC.start
    end

  end
end