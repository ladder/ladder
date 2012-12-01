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
      case marc
        when MARC::BookRecord
          rdf_types = {'Vocab::DBpedia' => ['Book'], 'Vocab::Bibo' => ['Book']}
        when MARC::SerialRecord
          rdf_types = {'Vocab::DBpedia' => ['PeriodicalLiterature'], 'Vocab::Bibo' => ['Periodical']}
        when MARC::MapRecord
          rdf_types = {'Vocab::Bibo' => ['Map']}
        when MARC::ScoreRecord
          rdf_types = {'Vocab::DBpedia' => ['MusicalWork']}
        when MARC::SoundRecord
          rdf_types = {'Vocab::Bibo' => ['AudioDocument']}
        when MARC::VisualRecord
          rdf_types = {'Vocab::Bibo' => ['AudioVisualDocument']}
        when MARC::ComputerRecord
          # NB: not 100% sure about this one
          rdf_types = {'Vocab::Schema' => ['SoftwareApplication']}
#        when MARC::MixedRecord
      end

      resource.rdf_types = rdf_types unless rdf_types.nil?
      resource.mods = @xslt.transform(Nokogiri::XML(Gyoku.xml(marc.to_gyoku_hash))).remove_namespaces!.to_xml#(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
      resource.save

      resource
    end

  end

end