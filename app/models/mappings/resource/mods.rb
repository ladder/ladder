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

    def map(resource, node)
      # make resource accessible to other methods
      @resource = resource

      # map MODS elements to embedded vocabs
      if resource.vocabs.empty?
        vocabs = map_vocabs(node)
        return if vocabs.values.map(&:values).flatten.empty?
        resource.vocabs = vocabs
      end

      # map encoded agents to related Agent models
      agents = map_agents(node.xpath('name[@usage="primary"]'))
      unless agents.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.creator = agents.map(&:id)
        resource.agents << agents
      end

      agents = map_agents(node.xpath('name[not(@usage="primary")]'))
      unless agents.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.contributor = agents.map(&:id)
        resource.agents << agents
      end

      agents = map_agents(node.xpath('originInfo/publisher'), {:foaf => {:name => '.'}})
      unless agents.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.publisher = agents.map(&:id)
        resource.agents << agents
      end

      # map encoded concepts to related Concept models
      concepts = map_concepts(node.xpath('subject[@authority]'))
      unless concepts.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.subject = concepts.map(&:id)
        resource.concepts << concepts
      end

      concepts = map_concepts(node.xpath('classification[@authority="ddc"]'))
      unless concepts.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.DDC = concepts.map(&:id)
        resource.concepts << concepts
      end

      concepts = map_concepts(node.xpath('classification[@authority="lcc"]'))
      unless concepts.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.LCC = concepts.map(&:id)
        resource.concepts << concepts
      end

      # map related resources as tree hierarchy
      relations = map_relations(node.xpath('relatedItem'))

      # assign relations at the right level
      if resource.parent.nil?
        resource.children << relations
        resource.save
      else
        resource.parent.children << relations
        resource.parent.save
      end

      resource
    end

    def map_vocabs(node)
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
          :identifier    => 'identifier[not(@type) or @type="local"]',

          # indexable textual content
          :abstract        => 'abstract',
          :tableOfContents => 'tableOfContents',

          # TODO: add <note>
      }

      bibo = map_xpath node, {
          # dereferenceable identifiers
          :isbn     => 'identifier[@type = "isbn"]',
          :issn     => 'identifier[@type = "issn"]',
          :lccn     => 'identifier[@type = "lccn"]',
          :oclcnum  => 'identifier[@type = "oclc"]',
          :upc      => 'identifier[@type = "upc"]',
          :doi      => 'identifier[@type = "doi"]',
          :uri      => 'identifier[@type = "uri"]',
      }

      prism = map_xpath node, {
          :edition          => 'originInfo/edition',
          :issueIdentifier  => 'identifier[@type = "issue-number" or @type = "issue number"]',
      }

      vocabs[:dcterms] = dcterms unless dcterms.empty?
      vocabs[:bibo] = bibo unless bibo.empty?
      vocabs[:prism] = prism unless prism.empty?

      vocabs
    end

    def map_relations(node_set)
      # @see: http://www.loc.gov/standards/mods/userguide/relateditem.html
      relations = []

      node_set.each do |node|
        # create/map related resource
        vocabs = map_vocabs(node)

        next if vocabs.values.map(&:values).flatten.empty?

        # recursively map related resources
        mapping = LadderMapping::MODS.new
        resource = Resource.find_or_create_by(vocabs)
        resource = mapping.map(resource, node)

        # TODO: clean up by abstracting?
        case node['type']
          # parent relationships
          when 'series'
            @resource.dcterms = DublinCore.new if @resource.dcterms.nil?
            resource.dcterms = DublinCore.new if resource.dcterms.nil?
            (@resource.dcterms.isPartOf ||= []) << resource.id
            (resource.dcterms.hasPart ||= []) << @resource.id
            resource.children << @resource
          when 'host'
            resource.children << @resource

          # child relationship
          when 'constituent'
            @resource.dcterms = DublinCore.new if @resource.dcterms.nil?
            resource.dcterms = DublinCore.new if resource.dcterms.nil?
            (@resource.dcterms.hasPart ||= []) << resource.id
            (resource.dcterms.isPartOf ||= []) << @resource.id
            @resource.children << resource

          # sibling-like relationships
          when 'otherVersion'
            @resource.dcterms = DublinCore.new if @resource.dcterms.nil?
            resource.dcterms = DublinCore.new if resource.dcterms.nil?
            (@resource.dcterms.hasVersion ||= []) << resource.id
            (resource.dcterms.isVersionOf ||= []) << @resource.id
            relations << resource
          when 'otherFormat'
            @resource.dcterms = DublinCore.new if @resource.dcterms.nil?
            resource.dcterms = DublinCore.new if resource.dcterms.nil?
            (@resource.dcterms.hasFormat ||= []) << resource.id
            (resource.dcterms.isFormatOf ||= []) << @resource.id
            relations << resource
          when 'isReferencedBy'
            @resource.dcterms = DublinCore.new if @resource.dcterms.nil?
            resource.dcterms = DublinCore.new if resource.dcterms.nil?
            (@resource.dcterms.isReferencedBy ||= []) << resource.id
            (resource.dcterms.references ||= []) << @resource.id
            relations << resource
          when 'references'
            @resource.dcterms = DublinCore.new if @resource.dcterms.nil?
            resource.dcterms = DublinCore.new if resource.dcterms.nil?
            (@resource.dcterms.references ||= []) << resource.id
            (resource.dcterms.isReferencedBy ||= []) << @resource.id
            relations << resource
          when 'original'
            @resource.prism = Prism.new if @resource.prism.nil?
            (@resource.prism.hasPreviousVersion ||= []) << resource.id
            relations << resource

          # undefined relationship
          # preceding, succeeding, reviewOf
          else
            relations << resource
        end

      end

      relations
    end

    def map_agents(node_set, opts={})
      agents = []
      agent_ids = @resource.agents.map(&:id)

      mapping = opts[:foaf] || {
          :name     => 'namePart[not(@type)] | displayForm',
          :birthday => 'namePart[@type = "date"]',
          :title    => 'namePart[@type = "termsOfAddress"]',
      }

      node_set.each do |node|

        foaf = map_xpath node, mapping
        next if foaf.values.flatten.empty?

        agent = Agent.find_or_create_by(:foaf => foaf)

        next if agent.nil? or agents.include? agent or agent_ids.include? agent.id

        agents << agent
      end

      agents
    end

    def map_concepts(node_set)
      concepts = []
      concept_ids = @resource.concepts.map(&:id)

      node_set.each do |node|
        # in MODS, each subject access point is usually composed of multiple
        # ordered sub-elements; so that's what we process for hierarchy
        # see: http://www.loc.gov/standards/mods/userguide/subject.html

        current = nil

        node.xpath('./text() | ./*').each do |subnode|
          next if subnode.text.strip.empty?

#          case subnode.name
#            when 'name'       # Agent
#            when 'titleInfo'  # Resource
#            else
              # NB: this xpath is slightly slower due to repetition, but simpler
              skos = map_xpath subnode, {:prefLabel  => 'preceding-sibling::* | .'}
              next if skos.values.flatten.empty?

              concept = Concept.find_or_create_by(:skos => skos)
#          end

          unless current.nil?
            # NB: semantically this seems redundant, but we do it for consistency
            (current.skos.narrower ||= []) << concept.id
            (concept.skos.broader ||= []) << current.id
            current.skos.narrower.uniq!
            concept.skos.broader.uniq!

            current.children << concept
            current.save
          end

          next if concepts.include? concept or concept_ids.include? concept.id

          concepts << concept
          current = concept
        end
      end

      concepts
    end

  end

end