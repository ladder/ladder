class MarcMapper < Mapper
  include Sidekiq::Worker

  def self.content_types
    ['application/marc', 'application/marc+xml', 'application/marc+json']
  end

  def perform(file_id, content_type)
    @file = Model::File.find(file_id)

    case content_type
      when 'application/marc'
        map_marc
      when 'application/marc+xml'
        map_marcxml
      when 'application/marc+json'
        map_json
      else
        raise ArgumentError, "Unsupported content type : #{content_type}"
    end

    rdf_types = detect_types(@marc)

    mods_xml = marc_to_mods(@marc_xml)

#    resource = Resource.create({:rdf_types => rdf_types})
#    resource.files << file
#    resource.groups << group

#    mods_mapping.map(resource, mods_xml.at_xpath('/mods'))
  end

  private

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