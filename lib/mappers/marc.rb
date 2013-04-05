class MarcMapper < Mapper

  def self.content_types
    ['application/marc', 'application/marc+xml', 'application/marc+json']
  end

  def perform(file_id)
    @file = Mongoid::GridFS.get(file_id)

    case @file.content_type
      when 'application/marc'
        parse_marc(@file.data)
      when 'application/marc+xml'
        parse_xml(@file.data)
      when 'application/marc+json'
        map_json(@file.data)
      else
        raise ArgumentError, "Unsupported content type : #{@file.content_type}"
    end
  end

  def parse_marc(data)
    # parse MARC data and return an array of File objects
    records = MARC::ForgivingReader.new(StringIO.new(data), :invalid => :replace) # TODO: may wish to include encoding options

    records.each do |record|
      map_marc(record)
    end
  end

  # TODO: make this a method on parent class
  def parse_xml(xml)
    # parse XML into records using XPath
    records = Nokogiri::XML(xml).remove_namespaces!.xpath('//record') # TODO: smarter namespace handling

    records.each do |record|
      map_xml(record)
    end
  end

  # map an individual binary MARC record
  def map_marc(marc_record)
    # load MARC record
#    marc_record = MARC::Record.new_from_marc(marc, :forgiving => true)

    # create MARC XML from MARC record
    marc_xml = Gyoku.xml(marc_record.to_gyoku_hash)

    # ensure weird encodings are turned into valid UTF-8
    marc_xml = marc_xml.encode('UTF-8', 'binary', :undef => :replace, :invalid => :replace, :replace =>'') unless marc_xml.force_encoding('UTF-8').valid_encoding?

    resource_from_marc(marc_record, marc_xml)
  end

  # map an individual MARCHASH record
  def map_json(marc_json)
    # load MARC record
    marc_record = MARC::Record.new_from_marchash(JSON.parse(marc_json))

    # create MARC XML from MARC record
    marc_xml = Gyoku.xml(marc_record.to_gyoku_hash)

    resource_from_marc(marc_record, marc_xml)
  end

  # map an individual MARCXML record
  def map_xml(marc_xml)
    # load MARC record
    marc_record = MARC::XMLReader.new(StringIO.new(marc_xml)).first # TODO: switch to :parser => :nokogiri

    resource = resource_from_marc(marc_record, marc_xml)
  end

  private

  # generate a fully-mapped Resource
  # by deferring to ModsMapper
  def resource_from_marc(marc, marc_xml)
    mods_xml = marc_to_mods(marc_xml)

    resource = ModsMapper.new.map_xml(mods_xml.root)

    resource.rdf_types.merge! detect_types(marc)
    resource.files << @file
    resource.save

    resource
=begin
    rdf_types = detect_types(marc)
    resource = Resource.create({:rdf_types => rdf_types})
    resource.groups << group
    mods_mapping.map(resource, mods_xml.at_xpath('/mods'))
=end
  end

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