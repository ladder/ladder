desc "Initialize default data values for the database"

namespace :model do
  task :init => :environment do

    # ensure indexes are mapped
    ['Resource', 'Agent', 'Concept'].each do |model|
      klass = model.classify.constantize

      # make sure the mapping is defined
      klass.put_mapping
    end
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
