desc "Map/Re-map Resources from MODS data"

namespace :map do
  task :mods, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    Mongoid.unit_of_work(disable: :all) do

      db_files = Model::File.where(:type => Model::File::MODS)

      # only select files which have not already been mapped
      # TODO: think about this
#      db_files = db_files.where(:resource_id.exists => false) unless !!args.remap

      exit if db_files.empty?

      puts "Mapping #{db_files.size} MODS files using #{Parallel.processor_count} processors..."

      # break resources into chunks for multi-processing
      chunks = db_files.chunkify

      # suppress indexing on save
      Resource.skip_callback(:save, :after, :update_index)
      Agent.skip_callback(:save, :after, :update_index)
      Concept.skip_callback(:save, :after, :update_index)

      Parallel.each_with_index(chunks) do |chunk, index|
        # force mongoid to create a new session for each chunk
        Mongoid::Sessions.clear

        chunk.each do |file|
          # load MODS XML document
          xml = Nokogiri::XML(file.data)

          # instantiate mapping object
          mapping = Mapping::MODS.new
          mapping.map(file.resource, xml.at_xpath('/mods'))
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