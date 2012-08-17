desc "Index/Re-Index models, optionally only for [model]"

namespace :tire do
  task :reindex, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.each do |model|
      # delete existing index
      index = Tire::Index.new(model.underscore.pluralize)
      index.delete if index.exists?
    end

    Rake::Task['tire:index'].execute#(:model => args.model) #TODO: fixme!
  end

  task :index, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.each do |model|

      klass  = model.classify.constantize
      break if klass.empty? # nothing to index

      # create the index if it doesn't exist
      klass.tire.create_elasticsearch_index

      # check whether anything is indexed already
      search = Tire.search(model.underscore.pluralize, :search_type => 'count') do
        query { all }
      end

      if 0 == search.results.total # nothing indexed yet
        collection = klass
      else
        # get last updated timestamp in the index
        search = Tire.search(model.underscore.pluralize) do
          query { all }
          sort { by :updated_at, 'desc' }
        end

        timestamp = search.results[0].updated_at
        collection = klass.where(:updated_at.gte => Time.parse(timestamp) + 1)
      end

      next if collection.empty?

      # do not include explicitly-mapped fields
      collection = collection.only(klass.mapping_to_hash[model.underscore.to_sym][:properties].keys)

      puts "Indexing #{collection.count} #{model.pluralize} with #{Parallel.processor_count} processors..."

      # break collection into chunks for multi-processing
      options = {:chunk_num => 1, :per_chunk => LadderHelper::dynamic_chunk(collection)}

      chunks = []
      while chunk = collection.page(options[:chunk_num]).per(options[:per_chunk]) \
                            and chunk.size(true) > 0
        chunks << chunk
        options[:chunk_num] += 1
      end

      # queries are executed in sequence, so traverse last-to-first
      chunks.reverse!

      # temporary settings to improve indexing performance
      klass.settings :refresh_interval => -1, :'merge.policy.merge_factor' => 30

      Parallel.each(chunks) do |chunk|
        # Make sure to reconnect after forking a new process
        Mongoid.reconnect!

        klass.tire.index.bulk_store chunk

        # Make sure to flush the GC when done a chunk
        GC.start
      end

      # restore default settings
      klass.settings :refresh_interval => '1s', :'merge.policy.merge_factor' => 10

    end

  end
end