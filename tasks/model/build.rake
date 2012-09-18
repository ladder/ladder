desc "Build tree hierarchy for documents, optionally only for [model]"

namespace :model do
  task :build, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.to_a.each do |model|

      klass  = model.classify.constantize
      next if klass.empty? # nothing to process

      # only retrieve fields required for hierarchy
      collection = klass.roots.only(:id, :parent_id, :parent_ids)

      puts "Building #{collection.count} #{model.pluralize} with #{Parallel.processor_count} processors..."

      # break collection into chunks for multi-processing
      chunks = LadderHelper::chunkify(collection)

      # suppress indexing on save
      klass.skip_callback(:save, :after, :update_index)

      Parallel.each(chunks) do |chunk|

        # save each document; this will only update the hierarchy
        chunk.each(&:save)

        # Make sure to flush the GC when done a chunk
        GC.start
      end

    end

  end
end