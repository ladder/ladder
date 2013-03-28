class MarcImporter < Importer
  @content_types = ['application/marc', 'application/marc+xml', 'application/marc+json']

  class << self; attr_reader :content_types end

  def import(data, content_type)
    case content_type
      when 'application/marc'
        parse_marc(data, content_type)
      when 'application/marc+xml'
        parse_marcxml(data, content_type)
      when 'application/marc+json'
        [Model::File.find_or_create_by({:data => data, :content_type => content_type})]
      else
        raise ArgumentError, "Unsupported content type : #{content_type}"
    end
  end

  private

  def parse_marc(marc, content_type)
    files = []

    # parse MARC data and return an array of File objects
    reader = MARC::Reader.new(marc, :invalid => :replace) # TODO: may wish to include encoding options

    reader.each do |record|
      # create a new file for this MARC record
      files << Model::File.find_or_create_by(:data => record.to_marc, :content_type => content_type)
    end

    files
  end

  def parse_marcxml(xml, content_type)
    files = []

    # parse XML into records using XPath
    records = Nokogiri::XML(xml).remove_namespaces!.xpath('//record') # TODO: smarter namespace handling

    records.each do |record|
      # create a new file for this <record> element
      files << Model::File.find_or_create_by(:data => record.to_xml(:encoding => 'UTF-8', :save_with => Nokogiri::XML::Node::SaveOptions::AS_XML), :content_type => content_type)
    end

    files
  end

end
