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
      node = xml.at_xpath('/mods')

      # map MODS elements to embedded vocabs
      @resource.vocabs = map_vocabs(node)

      # map related resources as tree hierarchy
      relations = map_relations(node.xpath('relatedItem'))

      unless relations[:parent].nil?
        @resource.parent = relations[:parent]
        @resource.parent.save
        @resource.parent.children << relations[:siblings]
      end

      @resource.children << relations[:children]

      # map encoded agents to related Agent models
      @resource.agents << map_agents(node.xpath('name'), 'dcterms.creator')

      # map encoded concepts to related Concept models
      @resource.concepts << map_concepts(node.xpath('subject[@authority]'), 'dcterms.subject')

      @resource
    end

    def map_vocabs(node)
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

:publisher => 'originInfo/publisher',

          # concept access points
          # TODO: move these to concepts
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

      vocabs = {}
      vocabs[:dcterms] = DublinCore.new(dcterms, :without_protection => true) #unless dcterms.empty?
      vocabs[:bibo] = Bibo.new(bibo, :without_protection => true) #unless bibo.empty?
      vocabs[:prism] = Prism.new # TODO: prism mapping

      vocabs
    end

    def map_relations(node_set)
      relations = {:parent => nil, :children => [], :siblings => []}

      node_set.each do |node|

        # apply vocab mapping to each related resource
        vocabs = map_vocabs(node)

        # FIXME: how to handle "empty" vocabs
        unless vocabs.empty?
          resource = Resource.new_or_existing(vocabs)

          # TODO: use some recursion here
#          (resource.agents ||= []) << map_agents(node.xpath('name'), 'dcterms.creator')

          case node['type']
            # parent relationships
            when 'series'
              (@resource.dcterms.isPartOf ||= []) << resource.id
              (resource.dcterms.hasPart ||= []) << @resource.id
              relations[:parent] = resource
            when 'host'
              relations[:parent] = resource

            # sibling-like relationships
            when 'otherVersion'
              (@resource.dcterms.hasVersion ||= []) << resource.id
              (resource.dcterms.isVersionOf ||= []) << @resource.id
              relations[:siblings] << resource
            when 'otherFormat'
              (@resource.dcterms.hasFormat ||= []) << resource.id
              (resource.dcterms.isFormatOf ||= []) << @resource.id
              relations[:siblings] << resource
            when 'isReferencedBy'
              (@resource.dcterms.isReferencedBy ||= []) << resource.id
              (resource.dcterms.references ||= []) << @resource.id
              relations[:siblings] << resource
            when 'references'
              (@resource.dcterms.references ||= []) << resource.id
              (resource.dcterms.isReferencedBy ||= []) << @resource.id
              relations[:siblings] << resource
            when 'original'
              (@resource.prism.hasPreviousVersion ||= []) << resource.id
              relations[:siblings] << resource

            # child relationship
            when 'constituent'
              (@resource.dcterms.hasPart ||= []) << resource.id
              (resource.dcterms.isPartOf ||= []) << @resource.id
              relations[:children] << resource

            # undefined relationship
            else
              relations[:siblings] << resource
          end

#          resource.save
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
          agent = Agent.new_or_existing(:foaf => FOAF.new(foaf))
          break if agents.include? agent

          agent.save
          agents << agent

          # append agent id to specified field
          value = @resource.send(ns).send(field)
          value << agent.id rescue value = [agent.id]
          @resource.send(ns).send(field + "=", value)
        end

      end

      agents
    end

    def map_concepts(node_set, target_field)
      concepts = []

      ns = target_field.split('.').first
      field = target_field.split('.').last

      node_set.each do |node|

        # in MODS, each subject access point is usually composed of multiple
        # ordered sub-elements; so that's what we process
        # see: http://www.loc.gov/standards/mods/userguide/subject.html

        root = nil
        current = nil

        node.element_children.each do |subnode|

          full ||= node.element_children.map(&:text).map(&:strip).uniq
          skos = {:prefLabel => [subnode.text.strip],
                  :hiddenLabel => full}

          concept = Concept.new_or_existing(:skos => SKOS.new(skos))
          break if concepts.include? concept

          concept.save

          if root.nil?
            root = concept
          else
            current.children << concept
          end

          current = concept
        end

        concepts << current

if root.nil?
  p @resource.id
  p node
  p node.element_children
  next
end
        # append concept id to specified field
        value = @resource.send(ns).send(field)
        value << root.id rescue value = [root.id]
        @resource.send(ns).send(field + "=", value)
      end

      concepts
    end

  end

end