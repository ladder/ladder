desc "Index/Re-Index models, optionally only for [model]"

namespace :tire do
  task :reindex, [:model] => :environment do |t, params|

    params.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    params.model.each do |model|
      # delete existing index
      index = Tire::Index.new(model.underscore.pluralize)
      index.delete if index.exists?
    end

    Rake::Task['tire:index'].execute#(:model => params.model) #TODO: fixme!
  end

  task :index, [:model] => :environment do |t, params|

    params.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    params.model.each do |model|

      klass  = model.classify.constantize
      break if klass.empty? # nothing to index

      # create the index if it doesn't exist
      index = Tire::Index.new(model.underscore.pluralize)

      if index.exists?
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

      else
        index.create :mappings => klass.tire.mapping_to_hash, :settings => klass.tire.settings
        collection = klass
      end

      next if collection.empty?

      # do not include explicitly-mapped fields
      collection = collection.only(klass.tire.mapping_to_hash[:resource][:properties].keys)

      puts "Indexing #{collection.count} #{model.pluralize} with #{Parallel.processor_count} processors..."

      # break collection into chunks for multi-processing
      options = {:chunk_num => 1, :per_chunk => LadderHelper::dynamic_chunk(collection)}

      chunks = []
      while chunk = collection.page(options[:chunk_num]).per(options[:per_chunk]) \
                            and chunk.size(true) > 0
        chunks << chunk
        options[:chunk_num] += 1
      end

      Parallel.each(chunks) do |chunk|

        # Import the documents
        options = options.merge({:page => 1, :per_page => 1000})

        chunk_array = chunk.to_a

        while documents = Kaminari.paginate_array(chunk_array).page(options[:page]).per(options[:per_page]) \
                            and documents.size > 0
          index.bulk_store documents
          options[:page] += 1
        end

      end

    end

  end
end