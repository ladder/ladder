desc "Re-index all model documents, optionally only for [model]"

namespace :tire do
  task :reindex, [:model] => :environment do |t, args|

    args.with_defaults(:model => ['Resource', 'Agent', 'Concept'])

    # once for each model specified
    args.model.to_a.each do |model|

      # delete existing index
      index = Tire::Index.new(model.underscore.pluralize)
      index.delete if index.exists?
    end

    Rake::Task['tire:index'].execute#(:model => args.model)
  end
end