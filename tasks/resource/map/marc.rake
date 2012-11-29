desc "Map/Re-map Resources from MARC data"

namespace :map do
  task :marc, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    Mongoid.unit_of_work(disable: :all) do

      resources = Resource.marc.only(:marc)

      # only select resources which have not already been mapped
      resources = resources.mods(false) unless !!args.remap

      exit if resources.empty?

      puts "Mapping #{resources.size} MARC records using #{Parallel.processor_count} processors..."

      # break resources into chunks for multi-processing
      chunks = resources.chunkify

      # suppress indexing on save
      Resource.reset_callbacks(:save)
      Resource.reset_callbacks(:validate)
      Resource.reset_callbacks(:validation)

      # instantiate mapping object
      mapping = Mapping::MARC2.new

      Parallel.each_with_index(chunks) do |chunk, index|
        # force mongoid to create a new session for each chunk
        Mongoid::Sessions.clear

        # TODO: we could do this in batches of 1000 (like import)
        # or skip storing the MODS and just map through directly
        chunk.each do |resource|
          mapping.map(resource)
        end

        puts "Finished chunk: #{(index+1)}/#{chunks.size}"

        # disconnect the session so we don't leave it orphaned
        Mongoid::Sessions.default.disconnect

        # Make sure to flush the GC when done a chunk
        GC.start
      end

    end

  end
end