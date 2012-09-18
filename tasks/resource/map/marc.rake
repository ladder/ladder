desc "Map/Re-map Resources from MARC data"

namespace :map do
  task :marc, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.marc

    # only select resources which have not already been mapped
    resources = resources.where(:mods.exists => false) unless args.remap

    exit if resources.empty?

    puts "Mapping #{resources.size(true)} Resources from MARC records using #{Parallel.processor_count} processors..."

    # break resources into chunks for multi-processing
    chunks = LadderHelper::chunkify(resources)

    # disable callbacks for indexing on save
    Resource.reset_callbacks(:save)
    Resource.reset_callbacks(:validate)
    Resource.reset_callbacks(:validation)

    # load MARC2MODS XSL once
    xslt_file = File.join(File.expand_path('../../../../lib/xslt', __FILE__), 'MARC21slim2MODS3-4.xsl')
    xslt = Nokogiri::XSLT(File.read(xslt_file))

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