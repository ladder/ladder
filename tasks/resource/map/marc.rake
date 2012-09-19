desc "Map/Re-map Resources from MARC data"

namespace :map do
  task :marc, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.marc.only(:marc)

    # only select resources which have not already been mapped
    resources = resources.mods(false) unless args.remap

    exit if resources.empty?

    puts "Mapping #{resources.size(true)} Resources from MARC records using #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    chunks = LadderHelper::chunkify(resources)

    # disable callbacks for indexing on save
    Resource.reset_callbacks(:save)
    Resource.reset_callbacks(:validate)
    Resource.reset_callbacks(:validation)

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