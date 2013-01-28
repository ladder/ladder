desc "Map/Re-map Resources from MODS data"

namespace :map do
  task :mods, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    Mongoid.unit_of_work(disable: :all) do

      db_files = Model::File.where(:content_type => 'application/mods+xml')

      # only select files which have not already been mapped
      db_files = db_files.where(:resource_id.exists => false) unless !!args.remap

      exit if db_files.empty?

      puts "Mapping #{db_files.size} MODS files using #{Parallel.processor_count} processors..."

      # break files into chunks for multi-processing
      chunks = db_files.chunkify

      # instantiate MODS mapping object
      mods_mapping = Mapping::MODS.new

      # suppress indexing on save
      Agent.skip_callback(:save, :after, :update_index)
      Concept.skip_callback(:save, :after, :update_index)
      Resource.skip_callback(:save, :after, :update_index)

      # create a group for this import
      group = Group.create({:type => 'Resource', :rdfs => {:label => ["Import #{Time.now}"]}})

      Parallel.each_with_index(chunks) do |chunk, index|
        # force mongoid to create a new session for each chunk
        Mongoid::Sessions.clear

        chunk.each do |file|
          # load MODS XML document
          mods = Nokogiri::XML(file.data)

          resource = mods_mapping.map(file.resource, mods.at_xpath('/mods'))
          resource.files << file
          resource.groups << group
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