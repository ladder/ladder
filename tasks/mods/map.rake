desc "Map/Re-map Resources from MODS data"

namespace :mods do

  task :map, [:remap] => :environment do |t, args|

    args.with_defaults(:remap => false)

    resources = Resource.only(:mods).where(:mods.exists => true)
    # only select resources which have not already been mapped
    unless args.remap
      resources = resources.where(:dcterms.exists => false, \
                                  :bibo.exists => false, \
                                  :prism.exists => false)
    end
    exit if resources.empty?

    puts "Mapping #{resources.size(true)} Resources from MODS records with #{Parallel.processor_count} processors..."

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

        # load MODS XML document
        mods = Nokogiri::XML(resource.mods).remove_namespaces!.root

        # dereferenceable identifiers
        bibo = {:isbn => mods.xpath_map('identifier[@type = "isbn"]'),
                :issn => mods.xpath_map('identifier[@type = "issn"]'),
                :lccn => mods.xpath_map('identifier[@type = "lccn"]'),
                :oclc => mods.xpath_map('identifier[@type = "oclc"]'),
        }.reject! { |k, v| v.nil? }

        prism = {}

        dcterms = {:title => mods.xpath_map('titleInfo[not(@type = "alternative")]'),
                   :alternative => mods.xpath_map('titleInfo[@type = "alternative"]'),
                   :issued => mods.xpath_map('originInfo/dateIssued'),
                   :format => mods.xpath_map('physicalDescription/form'),
                   :extent => mods.xpath_map('physicalDescription/extent'),
                   :language => mods.xpath_map('language/languageTerm'),

                   # dereferenceable identifiers
                   :identifier => mods.xpath_map('identifier[not(@type)]'),

                   # agent access points
                   :creator => mods.xpath_map('name/namePart[not(@type = "date")]'),
                   :publisher => mods.xpath_map('originInfo/publisher'),

                   # concept access points
                   :subject => mods.xpath_map('subject/topic'),
                   :spatial => mods.xpath_map('subject/geographic'),
                   :DDC => mods.xpath_map('classification[@authority="ddc"]'),
                   :LCC => mods.xpath_map('classification[@authority="lcc"]'),

                   # indexable textual content
                   :tableOfContents => mods.xpath_map('tableOfContents'),
        }.reject! { |k, v| v.nil? }

        # atomic set doesn't trigger callbacks (eg. index)
        resource.set(:dcterms, DublinCore.new(dcterms, :without_protection => true).as_document) unless dcterms.empty?
        resource.set(:bibo, Bibo.new(bibo, :without_protection => true).as_document) unless bibo.empty?
        resource.set(:prism, Prism.new(prism, :without_protection => true).as_document) unless prism.empty?
        resource.set(:updated_at, Time.now)
      end

    end

  end
end