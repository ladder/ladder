desc "Initialize default data values for the database"

namespace :app do
  task :init => :environment do

    # re-initialize mongodb
    Rake::Task['mi:purge'].invoke
    Rake::Task['mi:create_indexes'].invoke

    # remove existing ES index
    ENV['INDEX'] = "ladder_#{PADRINO_ENV}"
    Rake::Task['tire:index:drop'].invoke

    # ensure indexes are mapped
    %w[Agent Concept Resource].each {|model| model.classify.constantize.put_mapping}

    # create default admin account
    account = Account.create(:email => 'ladder@deliberatedata.com',
                             :name => 'Ladder',
                             :surname => 'Admin',
                             :password => 'ladder',
                             :password_confirmation => 'ladder',
                             :role => 'admin')

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
