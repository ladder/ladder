desc "Add documents to index, optionally only for [model]"

namespace :model do
  task :index, [:model, :reindex] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'], :reindex => false)

    Mongoid.unit_of_work(disable: :all) do

      # once for each model specified
      args.model.to_a.each do |model|

        klass = model.classify.constantize

        next if klass.empty? # nothing to index

        # make sure the mapping is defined
        klass.put_mapping

        # only retrieve fields that are mapped in index
        collection = klass.only(klass.get_mapping[:properties].keys)

        # only select documents which have not already been indexed
        collection = collection.unindexed unless !!args.reindex
        next if collection.empty?

        puts "Indexing #{collection.size} #{model.pluralize} using some processors..."

        # break collection into chunks for multi-processing
        chunks = collection.chunkify

        # temporary settings to improve indexing performance
        klass.settings :refresh_interval => -1, :'merge.policy.merge_factor' => 30

        chunks.each do |chunk, index|
          # force mongoid to create a new session for each chunk
          Mongoid::Sessions.clear

          klass.tire.index.bulk_store chunk

          puts "Finished chunk: #{(index+1)}/#{chunks.size}"

          # disconnect the session so we don't leave it orphaned
          Mongoid::Sessions.default.disconnect

          # Make sure to flush the GC when done a chunk
          GC.start
        end

        # restore default settings
        klass.settings :refresh_interval => '1s', :'merge.policy.merge_factor' => 10

      end

    end

  end
end
