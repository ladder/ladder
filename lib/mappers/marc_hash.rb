module Mappers

  class MarcHash < ::Mapper

    def self.content_types
      ['application/marc+json']
    end

    def perform(file_id)
      @file = Mongoid::GridFS.get(file_id)

      # create a MARC record
      marc_record = MARC::Record.new_from_marchash(JSON.parse(@file.data))

      # create MARC XML from MARC record
      marc_xml = Gyoku.xml(marc_record.to_gyoku_hash)

      # transform MARC XML to MODS via XSLT
      @@xslt ||= Nokogiri::XSLT(File.read(Padrino.root('lib/xslt', 'MARC21slim2MODS3-4.xsl')))
      mods_xml = @@xslt.transform(Nokogiri::XML(marc_xml)).remove_namespaces!

      # generate a fully-mapped Resource by delegating to MODS Mapper
      resource = Mods.new.map_mods(mods_xml.root)
      resource.rdf_types = detect_types(marc_record)

      # associate new Resource with its source file
      resource.files << @file

=begin
      resource.groups << group
      resource.save
=end
    end

    def detect_types(marc_record)
      # assign RDF class based on MARC class
      case marc_record
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

end