module LadderMapping

  class MARC2

    def initialize
      # load MARC2MODS XSL
      @xslt = Nokogiri::XSLT(File.read(Padrino.root('lib/xslt', 'MARC21slim2MODS3-4.xsl')))
    end

    def map(resource)
      # create MODS XML from MARC record
      marc = MARC::Record.new_from_marc(resource.marc, :forgiving => true)

      resource.mods = @xslt.transform(Nokogiri::XML(Gyoku.xml(marc.to_gyoku_hash))).remove_namespaces!.to_xml#(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
      resource.save

      resource
    end

  end

end