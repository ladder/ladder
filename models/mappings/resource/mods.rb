module LadderMapping
  class MODS

    def self.map_vocabs(xml_element)
      vocabs = {}

      dcterms = {# descriptive elements
                 :title => xml_element.xpath_map('titleInfo[not(@type = "alternative")]'),
                 :alternative => xml_element.xpath_map('titleInfo[@type = "alternative"]'),
                 :issued => xml_element.xpath_map('originInfo/dateIssued'),
                 :format => xml_element.xpath_map('physicalDescription/form'),
                 :extent => xml_element.xpath_map('physicalDescription/extent'),
                 :language => xml_element.xpath_map('language/languageTerm'),

                 # dereferenceable identifiers
                 :identifier => xml_element.xpath_map('identifier[not(@type)]'),

                 # agent access points
                 # TODO: move these to map_agents
                 :creator => xml_element.xpath_map('name/namePart[not(@type = "date")]'),
                 :publisher => xml_element.xpath_map('originInfo/publisher'),

                 # concept access points
                 # TODO: move these to map_concepts
                 :subject => xml_element.xpath_map('subject/topic'),
                 :spatial => xml_element.xpath_map('subject/geographic'),
                 :DDC => xml_element.xpath_map('classification[@authority="ddc"]'),
                 :LCC => xml_element.xpath_map('classification[@authority="lcc"]'),

                 # indexable textual content
                 :abstract => xml_element.xpath_map('abstract'),
                 :tableOfContents => xml_element.xpath_map('tableOfContents'),
      }.reject! { |k, v| v.nil? }

      # dereferenceable identifiers
      bibo = {:isbn => xml_element.xpath_map('identifier[@type = "isbn"]'),
                       :issn => xml_element.xpath_map('identifier[@type = "issn"]'),
                       :lccn => xml_element.xpath_map('identifier[@type = "lccn"]'),
                       :oclc => xml_element.xpath_map('identifier[@type = "oclc"]'),
      }.reject! { |k, v| v.nil? }

      # TODO: prism mapping

      vocabs[:dcterms] = DublinCore.new(dcterms, :without_protection => true) unless dcterms.empty?
      vocabs[:bibo] = Bibo.new(bibo, :without_protection => true) unless bibo.empty?

      vocabs
    end

    def self.map_related(xml_nodeset)
      children = []

      xml_nodeset.each do |node|
        # apply vocab mapping to each related resource
        resource = Resource.new(LadderMapping::MODS::map_vocabs(node))
        resource.set_created_at

        children << resource
        end

      children
    end

  end
end