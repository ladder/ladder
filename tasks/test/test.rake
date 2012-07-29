desc "Rake task test harness"

namespace :test do
  task :test, [:args] => :environment do |t, args|

#    stats =  Resource.collection.stats
#    num_obj = stats['count']
#    avg_size = stats['avgObjSize']

#    db = Resource.collection.db
#    db.stats
#    db.command('serverStatus' => 1)

  end
end
