desc "Map/Re-map Resources from MARC data"

namespace :map do
  task :marc, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.where(:marc.exists => true).only(:marc)

    # only select resources which have not already been mapped
    resources = resources.where(:mods.exists => false) unless args.remap

    exit if resources.empty?

    puts "Mapping #{resources.size(true)} MARC records using #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    chunks = LadderHelper::chunkify(resources)

    # suppress indexing on save
#    Resource.skip_callback(:save, :after, :update_index)
    Resource.reset_callbacks(:save)
    Resource.reset_callbacks(:validate)
    Resource.reset_callbacks(:validation)

    # instantiate mapping object
    mapping = LadderMapping::MARC.new

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|
        mapping.map(resource).save
      end

      # Make sure to flush the GC when done a chunk
      GC.start
    end

  end
end