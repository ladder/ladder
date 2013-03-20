desc "Initialize default data values for the database"

namespace :app do
  task :init => :environment do

    # remove existing DBs and ES index
    ENV['INDEX'] = "ladder_#{PADRINO_ENV}"
    Rake::Task['mi:purge'].invoke
    Rake::Task['tire:index:drop'].invoke

    # ensure indexes are mapped
    %w[Agent Concept Resource].each do |model|
      klass = model.classify.constantize
      klass.create_indexes
      klass.put_mapping
    end

  end
end
