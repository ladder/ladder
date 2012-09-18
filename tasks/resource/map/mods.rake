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

    mapping = LadderMapping::MODS.new

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|
        mapping.map(resource)
        mapping.save
      end

      # Make sure to flush the GC when done a chunk
      GC.start
    end

  end
end