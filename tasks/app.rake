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

    # create default admin account
    account = Account.create(:email => 'admin@deliberatedata.com',
                             :name => 'Ladder',
                             :surname => 'Admin',
                             :password => 'admin',
                             :password_confirmation => 'admin',
                             :role => 'admin')

    # create default user account
    account = Account.create(:email => 'ladder@deliberatedata.com',
                             :name => 'Ladder',
                             :surname => 'Test',
                             :password => 'ladder',
                             :password_confirmation => 'ladder',
                             :role => 'user')

=begin
    # Create groups for controlled vocabs
    %w[DDC LCSH LCC RVM].each do |group|
      Fabricate(:Group, type: 'Concept') do
        rdfs { Fabricate.build(:RDFS, label: [group])}
      end
    end

    # Create a default group for Resources
    Fabricate(:Group, type: 'Resource') do
      rdfs { Fabricate.build(:RDFS, label: ['Default'])}
    end
=end
  end
end
