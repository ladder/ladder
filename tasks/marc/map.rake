desc "Map/Re-map Resources from MARC data"

namespace :marc do

  task :map, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.marc

    # only select resources which have not already been mapped
    resources = resources.where(:mods.exists => false) unless args.remap

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

    # disable callbacks for indexing on save
    Resource.reset_callbacks(:save)
    Resource.reset_callbacks(:validate)

    Parallel.each(chunks) do |chunk|

      chunk.each do |resource|

        # create MODS XML from MARC record
        marc = MARC::Record.new_from_marc(resource.marc, :forgiving => true)

        resource.mods = xslt.transform(Nokogiri::XML(Gyoku.xml(marc.to_gyoku_hash))).to_s

        resource.save
      end

    end

  end
end