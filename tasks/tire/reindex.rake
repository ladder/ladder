desc "Re-index all documents, optionally only for [model]"

namespace :tire do
  task :reindex, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.to_a.each do |model|

      klass  = model.classify.constantize

      # delete existing index
      klass.tire.index.delete if klass.tire.index.exists?
      klass.tire.create_elasticsearch_index
    end

    Rake::Task['tire:index'].execute#(:model => args.model)
  end
end