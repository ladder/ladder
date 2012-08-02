desc "Map/Re-map Resources from MARC data"

namespace :marc do
  task :remap => :environment do

    resources = Resource.where(:marc.exists => true, :mods.exists => true)

    puts "Resetting #{resources.size} Resources with MARC records using #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    options = {:chunk_num => 1, :per_chunk => LadderHelper::dynamic_chunk(resources)}

    chunks = []
    while chunk = resources.page(options[:chunk_num]).per(options[:per_chunk]) \
                            and chunk.size(true) > 0
      chunks << chunk
      options[:chunk_num] += 1
    end

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|

        resource.unset(:mods)

      end
    end

    Rake::Task['marc:map'].execute
  end

  task :map => :environment do

    # load MARC2MODS XSL once
    xslt_file = File.join(File.expand_path('../../../lib/xslt', __FILE__), 'MARC21slim2MODS3-4.xsl')
    xslt = Nokogiri::XSLT(File.read(xslt_file))

    resources = Resource.only(:marc).where(:marc.exists => true, :mods.exists => false)

    exit if resources.empty?

    puts "Mapping #{resources.size} Resources from MARC records using #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    options = {:chunk_num => 1, :per_chunk => LadderHelper::dynamic_chunk(resources)}

    chunks = []
    while chunk = resources.page(options[:chunk_num]).per(options[:per_chunk]) \
                            and chunk.size(true) > 0
      chunks << chunk
      options[:chunk_num] += 1
    end

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|

        # create MODS XML from MARC record
        # TODO: should this be on import for better performance?
        if resource.marc.force_encoding('UTF-8').valid_encoding?
          marc = resource.marc
        else
          marc = resource.marc.encode!('UTF-8', 'UTF-8', :invalid => :replace)
        end

        marc = MARC::Record.new_from_marc(marc, :forgiving => true)
        mods = xslt.transform(Nokogiri::XML(Gyoku.xml(marc.to_gyoku_hash)))

        # atomic set doesn't trigger callbacks (eg. index)
        resource.set(:mods, CompressedBinary.new.serialize(mods.to_s))
      end

    end

  end
end