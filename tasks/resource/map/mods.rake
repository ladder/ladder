desc "Map/Re-map Resources from MODS data"

namespace :map do
  task :mods, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.where(:mods.exists => true).only(:mods)

    # only select resources which have not already been mapped
    resources = resources.where(:dcterms.exists => false) \
                         .where(:bibo.exists => false) \
                         .where(:prism.exists => false) \
                         unless args.remap

    exit if resources.empty?

    puts "Mapping #{resources.size(true)} MODS records with #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    chunks = LadderHelper::chunkify(resources)

    # suppress indexing on save
    Resource.skip_callback(:save, :after, :update_index)
    Agent.skip_callback(:save, :after, :update_index)

    # instantiate mapping object
    mapping = LadderMapping::MODS.new

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|
        mapping.map(resource).save
      end

      # Make sure to flush the GC when done a chunk
      GC.start
    end

  end
end