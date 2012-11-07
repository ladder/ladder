desc "Purge documents from mongodb"

namespace :mi do
  task :purge => :environment do

    # Mongoid.purge!
    collections = Mongoid::Sessions.default.collections

    collections.each do |collection|
      puts "* Purging collection #{collection.name}..."
      collection.drop
    end

  end
end
