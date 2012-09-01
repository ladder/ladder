desc "Build tree hierarchy for documents, optionally only for [model]"

namespace :tree do
  task :build, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.to_a.each do |model|

      klass  = model.classify.constantize
      next if klass.empty? # nothing to rebuild

      # suppress indexing on save
      klass.skip_callback(:save, :after, :update_index)

      collection = klass.roots.only(:id, :parent_id, :parent_ids)

      puts "Building #{collection.count} #{model.pluralize} with #{Parallel.processor_count} processors..."

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

      Parallel.each(chunks) do |chunk|
        # Make sure to reconnect after forking a new process
        Mongoid.reconnect!

        # save each document; this will only update the hierarchy
        chunk.each(&:save)

        # Make sure to flush the GC when done a chunk
        GC.start
      end

    end

  end
end