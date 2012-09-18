desc "Add documents to index, optionally only for [model]"

namespace :model do
  task :index, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.to_a.each do |model|

      klass  = model.classify.constantize
      next if klass.empty? # nothing to index

      # only retrieve fields that are mapped in index
      collection = klass.only(klass.mapping_to_hash[model.underscore.singularize.to_sym][:properties].keys)

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

      # delete and re-create the index
      klass.tire.index.delete if klass.tire.index.exists?
      klass.tire.create_elasticsearch_index

      # temporary settings to improve indexing performance
      klass.settings :refresh_interval => -1, :'merge.policy.merge_factor' => 30

      Parallel.each(chunks) do |chunk|

        klass.tire.index.bulk_store chunk

        # Make sure to flush the GC when done a chunk
        GC.start
      end

      # restore default settings
      klass.settings :refresh_interval => '1s', :'merge.policy.merge_factor' => 10

    end

  end
end