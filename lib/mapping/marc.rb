module Mapping

  class MARC2
    attr_reader :mods

    def initialize
      # load MARC2MODS XSL
      @xslt = Nokogiri::XSLT(File.read(Padrino.root('lib/xslt', 'MARC21slim2MODS3-4.xsl')))
    end

    def map(marc)
      # create MODS XML from MARC record
      marc_xml = Gyoku.xml(marc.to_gyoku_hash)

      # ensure weird encodings are turned into valid UTF-8
      marc_xml = marc_xml.encode('UTF-8', 'binary', :undef => :replace, :invalid => :replace, :replace =>'') unless marc_xml.force_encoding('UTF-8').valid_encoding?

      @mods = @xslt.transform(Nokogiri::XML(marc_xml)).remove_namespaces!

      # assign RDF class based on MARC class
      case marc
        when MARC::BookRecord
          rdf_types = {:dbpedia => [:Book],
                        :schema => [:Book],
                          :bibo => [:Book]}
        when MARC::SerialRecord
          rdf_types = {:dbpedia => [:PeriodicalLiterature],
                          :bibo => [:Periodical]}
        when MARC::MapRecord
          rdf_types = { :schema => [:Map],
                          :bibo => [:Map]}
        when MARC::ScoreRecord
          rdf_types = {:dbpedia => [:MusicalWork],
                        :schema => [:MusicRecording]}
        when MARC::SoundRecord
          rdf_types = {:dbpedia => [:AudioDocument]}
        when MARC::VisualRecord
          rdf_types = {:dbpedia => [:AudioVisualDocument]}
        when MARC::ComputerRecord
          # NB: not 100% sure about this one
          rdf_types = {:dbpedia => [:SoftwareApplication],
                        :schema => [:SoftwareApplication]}
#        when MARC::MixedRecord
      end

      # create a new Resource for this record
      @resource = Resource.create({:rdf_types => rdf_types})

      @resource
    end

  end

end