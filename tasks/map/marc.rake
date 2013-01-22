desc "Map/Re-map Resources from MARC data"

namespace :map do
  task :marc, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    Mongoid.unit_of_work(disable: :all) do

      db_files = Model::File.where(:content_type => 'application/marc')

      # only select files which have not already been mapped
      db_files = db_files.where(:resource_id.exists => false) unless !!args.remap

      exit if db_files.empty?

      puts "Mapping #{db_files.size} MARC files using #{Parallel.processor_count} processors..."

      # break files into chunks for multi-processing
      chunks = db_files.chunkify

      # instantiate MARC and MODS mapping objects
      marc_mapping = Mapping::MARC2.new
      mods_mapping = Mapping::MODS.new

      # suppress indexing on save
      Agent.skip_callback(:save, :after, :update_index)
      Concept.skip_callback(:save, :after, :update_index)
      Resource.skip_callback(:save, :after, :update_index)

      Parallel.each_with_index(chunks) do |chunk, index|
        # force mongoid to create a new session for each chunk
        Mongoid::Sessions.clear

        chunk.each do |file|
          # load MARC record
          marc = MARC::Record.new_from_marc(file.data, :forgiving => true)

          resource = marc_mapping.map(marc)
          resource.files << file

          mods_mapping.map(resource, marc_mapping.mods.at_xpath('/mods'))
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