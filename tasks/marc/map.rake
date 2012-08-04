desc "Map/Re-map Resources from MARC data"

namespace :marc do

  task :map, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.only(:marc).where(:marc.exists => true)
    # only select resources which have not already been mapped
    unless args.remap
      resources = resources.where(:mods.exists => false)
    end
    exit if resources.empty?

    puts "Mapping #{resources.size(true)} Resources from MARC records using #{Parallel.processor_count} processors..."

    # load MARC2MODS XSL once
    xslt_file = File.join(File.expand_path('../../../lib/xslt', __FILE__), 'MARC21slim2MODS3-4.xsl')
    xslt = Nokogiri::XSLT(File.read(xslt_file))

    # break resources into chunks for multi-processing
    options = {:chunk_num => 1, :per_chunk => LadderHelper::dynamic_chunk(resources)}
    chunks = []
    while chunk = resources.page(options[:chunk_num]).per(options[:per_chunk]) \
                            and chunk.size(true) > 0
      chunks << chunk
      options[:chunk_num] += 1
    end

    # queries are executed in sequence, so traverse last-to-first
    chunks.reverse!

    Parallel.each(chunks) do |chunk|
      # Make sure to reconnect after forking a new process
      Mongoid.reconnect!

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