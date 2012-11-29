module Mapping

  class MARC2

    def initialize
      # load MARC2MODS XSL
      @xslt = Nokogiri::XSLT(File.read(Padrino.root('lib/xslt', 'MARC21slim2MODS3-4.xsl')))
    end

    def map(resource)
      # create MODS XML from MARC record
      marc = MARC::Record.new_from_marc(resource.marc, :forgiving => true)

      # assign RDF class based on MARC class
      resource.rdf_types ||= []
      case marc
        when MARC::BookRecord
          resource.rdf_types << 'http://dbpedia.org/ontology/Book'
          resource.rdf_types << (Vocab::Bibo.to_uri / 'Book').to_s
        when MARC::SerialRecord
          resource.rdf_types << 'http://dbpedia.org/ontology/PeriodicalLiterature'
          resource.rdf_types << (Vocab::Bibo.to_uri / 'Periodical').to_s
        when MARC::MapRecord
          resource.rdf_types << (Vocab::Bibo.to_uri / 'Map').to_s
        when MARC::ScoreRecord
          resource.rdf_types << 'http://dbpedia.org/ontology/MusicalWork'
        when MARC::SoundRecord
          resource.rdf_types << (Vocab::Bibo.to_uri / 'AudioDocument').to_s
        when MARC::VisualRecord
          resource.rdf_types << (Vocab::Bibo.to_uri / 'AudioVisualDocument').to_s
        when MARC::ComputerRecord
          # NB: not 100% sure about this one
          resource.rdf_types << 'http://schema.org/SoftwareApplication'
#        when MARC::MixedRecord
      end

      resource.mods = @xslt.transform(Nokogiri::XML(Gyoku.xml(marc.to_gyoku_hash))).remove_namespaces!.to_xml#(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
      resource.save

      resource
    end

  end

end