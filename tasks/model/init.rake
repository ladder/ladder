desc "Initialize default data values for the database"

namespace :model do
  task :init => :environment do

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

  end
end
