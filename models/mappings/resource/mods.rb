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

                 # indexable textual content
                 :abstract => xml_element.xpath_map('abstract'),
                 :tableOfContents => xml_element.xpath_map('tableOfContents'),

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
      }.reject! { |k, v| v.nil? }

      # dereferenceable identifiers
      bibo = {:isbn => xml_element.xpath_map('identifier[@type = "isbn"]'),
              :issn => xml_element.xpath_map('identifier[@type = "issn"]'),
              :lccn => xml_element.xpath_map('identifier[@type = "lccn"]'),
              :oclcnum => xml_element.xpath_map('identifier[@type = "oclc"]'),
      }.reject! { |k, v| v.nil? }

      # TODO: prism mapping

      vocabs[:dcterms] = DublinCore.new(dcterms) unless dcterms.empty?
      vocabs[:bibo] = Bibo.new(bibo) unless bibo.empty?

      vocabs
    end

    def self.map_relations(xml_nodeset)
      relations = {:children => [], :siblings => [], :fields => {}}

      xml_nodeset.each do |node|

        # apply vocab mapping to each related resource
        resource = Resource.new(self.map_vocabs(node))
        resource.set_created_at

        case node['type']
          when 'host'
            relations[:parent] = resource
          when 'series'
            relations[:parent] = resource
            (relations[:fields][:'dcterms.isPartOf'] ||= []).push(resource.id)

          when 'constituent'
            relations[:children].push(resource)
            (relations[:fields][:'dcterms.hasPart'] ||= []).push(resource.id)

          when 'otherVersion'
            relations[:siblings].push(resource)
            (relations[:fields][:'dcterms.hasVersion'] ||= []).push(resource.id)
          when 'otherFormat'
            relations[:siblings].push(resource)
            (relations[:fields][:'dcterms.hasFormat'] ||= []).push(resource.id)
          when 'isReferencedBy'
            relations[:siblings].push(resource)
            (relations[:fields][:'dcterms.isReferencedBy'] ||= []).push(resource.id)
          when 'references'
            relations[:siblings].push(resource)
            (relations[:fields][:'dcterms.references'] ||= []).push(resource.id)
          when 'original'
            relations[:siblings].push(resource)
            (relations[:fields][:'dcterms.hasPreviousVersion'] ||= []).push(resource.id)

          else
            relations[:siblings].push(resource)
        end

      end

      relations
    end

    def self.map_agents(xml_nodeset)
      agents = []
    end

    def self.map_concepts(xml_nodeset)
      concepts = []
    end

  end
end