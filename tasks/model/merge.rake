desc "Merge duplicate documents, optionally only for [model]"

namespace :model do
  task :merge, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.to_a.each do |model|

      klass  = model.classify.constantize
      next if klass.empty? # nothing to process

      # only retrieve fields that are mapped in index
      collection = klass.only(klass.mapping_to_hash[model.underscore.singularize.to_sym][:properties].keys)

      puts "Merging #{collection.count} #{model.pluralize} with #{Parallel.processor_count} processors..."

      # break collection into chunks for multi-processing
      chunks = LadderHelper::chunkify(collection)

      # disable callbacks for indexing and tree generation on save
      klass.reset_callbacks(:save)
      klass.reset_callbacks(:validate)
      klass.reset_callbacks(:validation)

      Parallel.each(chunks) do |chunk|
        deleted = []

        chunk.each do |doc|
          # don't bother with deleted documents in the same chunk
          next if deleted.include? doc.id.to_s

          doc.same.each do |duplicate|
            # we can't process duplicates that are already parented
            next if duplicate.parent_id

            # make sure the document doesn't exist in mongo (process-safety)
            check = klass.all.for_ids(duplicate.id).entries
            next if check.empty?

            item = check.first

            # == TODO: refactor this into a LadderModel method

            # move_children_to_parent with self context
            item.children.each do |c|
              c.parent_id = doc.id
              c.save
            end

            # TODO: remove relations: agents, concepts, etc

            # mark duplicate as deleted in mongo and remove from index
            item.remove
            item.index.remove item

            # == END TODO

            deleted << duplicate.id

            puts "Merged #{duplicate.id} into #{doc.id} (#{item.heading})"
          end

        end

        # Make sure to flush the GC when done a chunk
        GC.start
      end

    end

  end
end
