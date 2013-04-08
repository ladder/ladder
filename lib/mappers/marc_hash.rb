module Mapper
  class MarcHash < Mapper

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
      # TODO: preload/precompile this somewhere within the application
      xslt = Nokogiri::XSLT(File.read(Padrino.root('lib/xslt', 'MARC21slim2MODS3-4.xsl')))

      mods_xml = xslt.transform(Nokogiri::XML(marc_xml)).remove_namespaces!

      # generate a fully-mapped Resource by delegating to MODS Mapper
      resource = Mapper::Mods.new.map_xml(mods_xml.root)

=begin
    rdf_types = detect_types(marc)
    resource = Resource.create({:rdf_types => rdf_types})
    resource.groups << group
=end
      resource.files << @file
      resource.save

      resource
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
end