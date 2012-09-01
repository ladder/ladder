desc "Merge duplicate documents, optionally only for [model]"

namespace :tree do
  task :merge, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.to_a.each do |model|

      klass  = model.classify.constantize
      next if klass.empty? # nothing to rebuild

      # only retrieve fields that are mapped in index
      collection = klass.only(klass.mapping_to_hash[model.underscore.to_sym][:properties].keys)

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

      # suppress indexing on save
      klass.skip_callback(:save, :after, :update_index)

      # disable callbacks for indexing and tree generation on save
      klass.reset_callbacks(:save)
      klass.reset_callbacks(:validate)
      klass.reset_callbacks(:validation)

      Parallel.each(chunks) do |chunk|
        # Make sure to reconnect after forking a new process
        Mongoid.reconnect!

        chunk.each do |doc|
#doc.find_similar
        end

        # Make sure to flush the GC when done a chunk
        GC.start
      end

    end

  end
end
