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

    def map(resource)
      @resource = resource

      # load MODS XML document
      xml = Nokogiri::XML(@resource.mods).remove_namespaces!

      # map MODS elements to embedded vocabs
      @resource.vocabs = map_vocabs(xml.xpath('/mods').first)

      # map related resources as tree hierarchy
      relations = map_relations(xml.xpath('/mods/relatedItem'))

      @resource.parent = relations[:parent]
      @resource.parent.children << relations[:siblings] unless @resource.parent.nil?
      @resource.children << relations[:children]

      # map encoded agents to related Agent models
      @resource.agents << map_agents(xml.xpath('/mods/name'), 'dcterms.creator')

      # FIXME: this won't match the agent mapping
      @resource.agents << map_agents(xml.xpath('/mods/originInfo/publisher'), 'dcterms.publisher')

      # map encoded concepts to related Concept models
      #@resource.concepts << concepts(xml.xpath('/mods/subject'))

      @resource
    end

    def save
#     @resource.children.map(&:save)
      @resource.parent.save unless @resource.parent.nil?
      @resource.set_updated_at
      @resource.save
    end

    def map_vocabs(node)
      vocabs = {:dcterms => {}, :bibo => {}, :prism => {}}

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

      vocabs[:dcterms] = DublinCore.new(dcterms, :without_protection => true)# unless dcterms.empty?
      vocabs[:bibo] = Bibo.new(bibo, :without_protection => true)# unless bibo.empty?
      vocabs[:prism] = {} # TODO: prism mapping

      vocabs
    end

    def map_relations(node_set)
      relations = {:parent => nil, :children => [], :siblings => []}

      node_set.each do |node|

        # apply vocab mapping to each related resource
        vocabs = map_vocabs(node)

        # FIXME: how to handle "empty" vocabs
        unless vocabs.empty?
          resource = Resource.new
          resource.set_created_at
          resource.vocabs = vocabs

          case node['type']
            # parent relationships
            when 'series'
              relations[:parent] = resource
              (@resource.dcterms.isPartOf ||= []) << resource.id
              (resource.dcterms.hasPart ||= []) << @resource.id
            when 'host'
              relations[:parent] = resource

            # sibling-like relationships
            when 'otherVersion'
              relations[:siblings] << resource
              (@resource.dcterms.hasVersion ||= []) << resource.id
              (resource.dcterms.isVersionOf ||= []) << @resource.id
            when 'otherFormat'
              relations[:siblings] << resource
              (@resource.dcterms.hasFormat ||= []) << resource.id
              (resource.dcterms.isFormatOf ||= []) << @resource.id
            when 'isReferencedBy'
              relations[:siblings] << resource
              (@resource.dcterms.isReferencedBy ||= []) << resource.id
              (resource.dcterms.references ||= []) << @resource.id
            when 'references'
              relations[:siblings] << resource
              (@resource.dcterms.references ||= []) << resource.id
              (resource.dcterms.isReferencedBy ||= []) << @resource.id
            when 'original'
              relations[:siblings] << resource
              (@resource.prism.hasPreviousVersion ||= []) << resource.id

            # child relationship
            when 'constituent'
              relations[:children] << resource
              (@resource.dcterms.hasPart ||= []) << resource.id
              (resource.dcterms.isPartOf ||= []) << @resource.id

            # undefined relationship
            else
              relations[:siblings] << resource
          end
        end

      end

      if relations[:parent].nil? and !relations[:siblings].empty?
        relations[:children] << relations[:siblings]
        relations[:siblings] = []
      end

      relations
    end

    def map_agents(node_set, target_field)
      agents = []

      ns = target_field.split('.').first
      field = target_field.split('.').last

      node_set.each do |node|

        foaf = map_xpath node, {
            # TODO: additional parsing/mapping
            :name     => 'namePart[not(@type)]',
            :birthday => 'namePart[@type = "date"]',
            :title    => 'namePart[@type = "termsOfAddress"]',
        }

        # FIXME: how to handle "empty" vocabs
        unless foaf.empty?
          agent = Agent.new
          agent.set_created_at
          agent.vocabs = {:foaf => FOAF.new(foaf)}
          agents << agent

          value = @resource.send(ns).send(field)
          value << agent.id rescue value = [agent.id]
          @resource.send(ns).send(field + "=", value)
        end

      end

      agents
    end

    def concepts(xml_nodeset)
      concepts = []
    end

  end

end