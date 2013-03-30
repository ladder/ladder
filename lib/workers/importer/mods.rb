class ModsImporter < Importer
  include Sidekiq::Worker

  def self.content_types
    ['application/mods+xml']
  end

  def perform(data, content_type)
    case content_type
      when 'application/mods+xml'
        parse_modsxml(data, content_type)
      else
        raise ArgumentError, "Unsupported content type : #{content_type}"
    end
  end

  private

  def parse_modsxml(xml, content_type)
    files = []

    # parse XML into records using XPath
    records = Nokogiri::XML(xml).remove_namespaces!.xpath('//mods') # TODO: smarter namespace handling

    records.each do |record|
      # create a new file for this <mods> element
      files << Model::File.find_or_create_by(:data => record.to_xml(:encoding => 'UTF-8'), :content_type => content_type)
    end

    files
  end

end
