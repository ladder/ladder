desc "Add documents to index, optionally only for [model]"

namespace :model do
  task :index, [:model, :reindex] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'], :reindex => false)

    Mongoid.unit_of_work(disable: :all) do

      # once for each model specified
      args.model.to_a.each do |model|

        klass  = model.classify.constantize
        next if klass.empty? # nothing to index

        # only retrieve fields that are mapped in index
        collection = klass.only(klass.mapping_to_hash[model.underscore.singularize.to_sym][:properties].keys)

        # TODO: make this a scope on LadderModel
        # only select documents which have not already been indexed
        unless !!args.reindex

          s = Tire.search model.underscore.pluralize do
            query { all }
            sort { by :_timestamp, 'desc' }
            size 1
          end

          # if there's a timestamp in the index, use that as the offset
          unless s.results.empty?
            timestamp = s.results.first.sort.first / 1000
            collection = collection.or(:updated_at.gte => timestamp, :created_at.gte => timestamp)
          end

          next if collection.empty?
        end

        puts "Indexing #{collection.size} #{model.pluralize} using #{Parallel.processor_count} processors..."

        # break collection into chunks for multi-processing
        chunks = collection.chunkify

        # ensure the index exists
        klass.tire.create_elasticsearch_index

        # temporary settings to improve indexing performance
        klass.settings :refresh_interval => -1, :'merge.policy.merge_factor' => 30

        Parallel.each_with_index(chunks) do |chunk, index|
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
