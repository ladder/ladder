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

      puts "Building #{collection.size} #{model.pluralize} using #{Parallel.processor_count} processors..."

      # break collection into chunks for multi-processing
      chunks = collection.chunkify

      # suppress indexing on save
      klass.skip_callback(:save, :after, :update_index)

      Parallel.each(chunks) do |chunk|
        # force mongoid to create a new session for each chunk
        Mongoid::Sessions.clear

        # save each document; this will only update the hierarchy
        chunk.each(&:save)

        # disconnect the session so we don't leave it orphaned
        Mongoid::Sessions.default.disconnect

        # Make sure to flush the GC when done a chunk
        GC.start
      end

    end

  end
end