class MarcMapper < Mapper

  def self.content_types
    ['application/marc', 'application/marc+xml', 'application/marc+json']
  end

  def perform(file_id)
    @file = Model::File.find(file_id)

    case @file.content_type
      when 'application/marc'
        map_marc
      when 'application/marc+xml'
        map_marcxml
      when 'application/marc+json'
        map_json
      else
        raise ArgumentError, "Unsupported content type : #{@file.content_type}"
    end

    rdf_types = detect_types(@marc)

    mods_xml = marc_to_mods(@marc_xml)

#    resource = Resource.create({:rdf_types => rdf_types})
#    resource.files << file
#    resource.groups << group

#    mods_mapping.map(resource, mods_xml.at_xpath('/mods'))
  end

  private
=begin
  def parse_marc(marc, content_type)
    files = []

    # parse MARC data and return an array of File objects
    reader = MARC::ForgivingReader.new(marc, :invalid => :replace) # TODO: may wish to include encoding options

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
=end
  def map_marc
    # load MARC record
    @marc = MARC::Record.new_from_marc(@file.data, :forgiving => true)

    # create MARC XML from MARC record
    @marc_xml = Gyoku.xml(marc.to_gyoku_hash)

    # ensure weird encodings are turned into valid UTF-8
    @marc_xml = marc_xml.encode('UTF-8', 'binary', :undef => :replace, :invalid => :replace, :replace =>'') unless marc_xml.force_encoding('UTF-8').valid_encoding?
  end

  def map_marcxml
    # load MARC record
    @marc = MARC::XMLReader.new(StringIO.new(@file.data)).first # TODO: switch to :parser => :nokogiri

    @marc_xml = @file.data
  end

  def map_json
    # load MARC record
    @marc = MARC::Record.new_from_marchash(JSON.parse(@file.data).to_hash)

    # create MARC XML from MARC record
    @marc_xml = Gyoku.xml(@marc.to_gyoku_hash)
  end

  private

  def marc_to_mods(marc_xml)
    # load MARC2MODS XSL
    xslt = Nokogiri::XSLT(File.read(Padrino.root('lib/xslt', 'MARC21slim2MODS3-4.xsl')))

    xslt.transform(Nokogiri::XML(marc_xml)).remove_namespaces!
  end

  def detect_types(marc)
    # assign RDF class based on MARC class
    case marc
      when MARC::BookRecord
        {:dbpedia => [:Book], :schema => [:Book], :bibo => [:Book]}
      when MARC::SerialRecord
        {:dbpedia => [:PeriodicalLiterature], :bibo => [:Periodical]}
      when MARC::ScoreRecord
        {:dbpedia => [:MusicalWork], :schema => [:MusicRecording]}
      when MARC::SoundRecord
        {:dbpedia => [:AudioDocument]}
      when MARC::VisualRecord
        {:dbpedia => [:AudioVisualDocument]}
      when MARC::ComputerRecord
        # NB: not 100% sure about this one
        {:dbpedia => [:SoftwareApplication], :schema => [:SoftwareApplication]}
      when MARC::MapRecord
        {:schema => [:Map], :bibo => [:Map]}
      #when MARC::MixedRecord
    end

  end

end