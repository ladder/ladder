module LadderMapping

  class MODS

    # TODO: abstract to generic mapping module/class
    def map_xpath(xml_node, hash)
      mapped = {}

      hash.each do |symbol, xpath|
        nodes = xml_node.xpath(xpath).map(&:text).map(&:strip).uniq
        mapped[symbol] = nodes unless nodes.empty?
      end

      mapped
    end

    def vocabs(node)
      vocabs = {}

      dcterms = map_xpath node, {
          # descriptive elements
          :title         => 'titleInfo[not(@type = "alternative")]',
          :alternative   => 'titleInfo[@type = "alternative"]',
          :issued        => 'originInfo/dateIssued',
          :format        => 'physicalDescription/form',
          :extent        => 'physicalDescription/extent',
          :language      => 'language/languageTerm',
          # dereferenceable identifiers
          :identifier    => 'identifier[not(@type)]',
          # indexable textual content
          :abstract        => 'abstract',
          :tableOfContents => 'tableOfContents',

          # agent access points
          # TODO: move these to agents
          :creator       => 'name/namePart[not(@type = "date")]',
          :publisher     => 'originInfo/publisher',

          # concept access points
          # TODO: move these to concepts
          :subject       => 'subject/topic',
          :spatial       => 'subject/geographic',
          :DDC           => 'classification[@authority="ddc"]',
          :LCC           => 'classification[@authority="lcc"]',
      }

      bibo = map_xpath node, {
          # dereferenceable identifiers
          :isbn     => 'identifier[@type = "isbn"]',
          :issn     => 'identifier[@type = "issn"]',
          :lccn     => 'identifier[@type = "lccn"]',
          :oclcnum  => 'identifier[@type = "oclc"]',
      }

      # TODO: prism mapping
      vocabs[:dcterms] = DublinCore.new(dcterms, :without_protection => true) unless dcterms.empty?
      vocabs[:bibo] = Bibo.new(bibo, :without_protection => true) unless bibo.empty?

      vocabs
    end

    def relations(xml_nodeset)
      relations = {:children => [], :siblings => [],
                   :fields => {:dcterms => {}, :bibo => {}, :prism => {}}}

      xml_nodeset.each do |node|

        # apply vocab mapping to each related resource
        vocabs = vocabs(node)

        unless vocabs.empty?
          resource = Resource.new(vocabs)
          resource.set_created_at

          # TODO: map inverse relations on created Resources?
          case node['type']
            when 'host'
              relations[:parent] = resource
            when 'series'
              relations[:parent] = resource
              (relations[:fields][:dcterms][:isPartOf] ||= []).push(resource.id)

            when 'constituent'
              relations[:children] << resource
              (relations[:fields][:dcterms][:hasPart] ||= []).push(resource.id)

            when 'otherVersion'
              relations[:siblings] << resource
              (relations[:fields][:dcterms][:hasVersion] ||= []).push(resource.id)
            when 'otherFormat'
              relations[:siblings] << resource
              (relations[:fields][:dcterms][:hasFormat] ||= []).push(resource.id)
            when 'isReferencedBy'
              relations[:siblings] << resource
              (relations[:fields][:dcterms][:isReferencedBy] ||= []).push(resource.id)
            when 'references'
              relations[:siblings] << resource
              (relations[:fields][:dcterms][:references] ||= []).push(resource.id)
            when 'original'
              relations[:siblings] << resource
              (relations[:fields][:prism][:hasPreviousVersion] ||= []).push(resource.id)

            else
              relations[:siblings].push(resource)
          end

        end

      end

      relations
    end

    def agents(xml_nodeset)
      agents = {:agents => [],
                :fields => {:dcterms => {}, :bibo => {}, :prism => {}}}

      xml_nodeset.each do |node|
        vocabs = {}

        foaf = map_xpath node, {
            # TODO: additional parsing/mapping
            :name     => 'namePart[not(@type = "date")]',
            :birthday => 'namePart[@type = "date"]',
        }

        # TODO: this structure is just to copy that above; refactor together
        vocabs[:foaf] = FOAF.new(foaf, :without_protection => true)

        unless foaf.empty?
          agent = Agent.new(vocabs)
          agent.set_created_at

          # FIXME: assume that all agents are creators?
          agents[:agents] << agent
          (agents[:fields][:dcterms][:creator] ||= []).push(agent.id)
        end

      end

      agents
    end

    def concepts(xml_nodeset)
      concepts = []
    end

    def map(resource)
      @resource = resource

      # load MODS XML document
      xml = Nokogiri::XML(@resource.mods).remove_namespaces!

      # map MODS elements to embedded vocabs
      @resource.vocabs = vocabs(xml.xpath('/mods').first)

      # NB: there might be a better way to assign embedded attributes
#        vocabs.each do |ns, vocab|
#          @resource.write_attribute(ns, vocab)
#        end

      # map related resources as tree hierarchy
      relations = relations(xml.xpath('/mods/relatedItem'))
      @resource.assign_attributes(relations[:fields])

      if relations[:parent].nil?
        # if resource does not have a parent, assign siblings as children
        children = relations[:siblings]
      else
        children = []

        relations[:parent].save
        @resource.parent = relations[:parent]
        relations[:siblings].each do |sibling|
          @resource.parent.children << sibling
        end
      end

      @resource.children = children + relations[:children]

      # map encoded agents to related Agent models; store relation types in vocab fields
      agents = agents(xml.xpath('/mods/name'))
      @resource.assign_attributes(agents[:fields])
      @resource.agents << agents[:agents]

      # map encoded agents to related Agent models; store relation types in vocab fields
#        concepts = concepts(xml.xpath('/mods/name'))
#        @resource.assign_attributes(concepts[:fields])
#        @resource.concepts << concepts[:concepts]

      @resource
    end

    def save
      @resource.save
    end

  end

end