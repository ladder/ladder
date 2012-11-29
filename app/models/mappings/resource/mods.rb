module Mapping

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
      concepts = map_concepts(node.xpath('subject/geographicCode'))
      unless concepts.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.spatial = concepts.map(&:id)
        resource.concepts << concepts
      end

      concepts = map_concepts(node.xpath('subject[not(@authority="lcsh") and not(geographicCode)]'))
      unless concepts.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.subject = concepts.map(&:id)
        resource.concepts << concepts
      end

      concepts = map_concepts(node.xpath('subject[@authority="lcsh"]'))
      unless concepts.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.LCSH = concepts.map(&:id)
        resource.concepts << concepts
      end

      concepts = map_concepts(node.xpath('subject[@authority="rvm"]'))
      unless concepts.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.RVM = concepts.map(&:id)
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

      # map related Resources as tree hierarchy

      # NB: these relationships are poorly defined
      relations = map_relations(node.xpath('relatedItem[not(@type) or @type="preceding" or @type="succeeding" or @type="reviewOf"]'))
      unless relations.empty?
        relations.each do |relation|
          resource.children << relation
        end
      end

      relations = map_relations(node.xpath('relatedItem[@type="host"]'))
      unless relations.empty?
        relations.each do |relation|
          relation.children << resource
        end
      end

      relations = map_relations(node.xpath('relatedItem[@type="series"]'))
      unless relations.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.isPartOf = relations.map(&:id)

        relations.each do |relation|
          relation.dcterms = DublinCore.new if relation.dcterms.nil?
          relation.dcterms.hasPart = [resource.id]
          relation.children << resource
        end
      end

      relations = map_relations(node.xpath('relatedItem[@type="constituent"]'))
      unless relations.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.hasPart = relations.map(&:id)

        relations.each do |relation|
          relation.dcterms = DublinCore.new if relation.dcterms.nil?
          relation.dcterms.isPartOf = [resource.id]
          resource.children << relation
        end
      end

      relations = map_relations(node.xpath('relatedItem[@type="original"]'))
      unless relations.empty?
        relations.each do |relation|
          if resource.root?
            resource.children << relation
          else
            resource.parent.children << relation
          end
        end
      end

      relations = map_relations(node.xpath('relatedItem[@type="isReferencedBy"]'))
      unless relations.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.isReferencedBy = relations.map(&:id)

        relations.each do |relation|
          relation.dcterms = DublinCore.new if relation.dcterms.nil?
          relation.dcterms.references = [resource.id]

          if resource.root?
            resource.children << relation
          else
            resource.parent.children << relation
          end
        end
      end

      relations = map_relations(node.xpath('relatedItem[@type="references"]'))
      unless relations.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.references = relations.map(&:id)

        relations.each do |relation|
          relation.dcterms = DublinCore.new if relation.dcterms.nil?
          relation.dcterms.isReferencedBy = [resource.id]

          if resource.root?
            resource.children << relation
          else
            resource.parent.children << relation
          end
        end
      end

      relations = map_relations(node.xpath('relatedItem[@type="otherVersion"]'))
      unless relations.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.hasVersion = relations.map(&:id)

        relations.each do |relation|
          relation.dcterms = DublinCore.new if relation.dcterms.nil?
          relation.dcterms.isVersionOf = [resource.id]

          if resource.root?
            resource.children << relation
          else
            resource.parent.children << relation
          end
        end
      end

      relations = map_relations(node.xpath('relatedItem[@type="otherFormat"]'))
      unless relations.empty?
        resource.dcterms = DublinCore.new if resource.dcterms.nil?
        resource.dcterms.hasFormat = relations.map(&:id)

        relations.each do |relation|
          relation.dcterms = DublinCore.new if relation.dcterms.nil?
          relation.dcterms.isFormatOf = [resource.id]

          if resource.root?
            resource.children << relation
          else
            resource.parent.children << relation
          end
        end
      end

      # save modifications to hierarchy
      resource.root.save

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
        resource = Resource.find_or_create_by(vocabs)

        mapping = Mapping::MODS.new
        resource = mapping.map(resource, node)

        next if resource.nil? or relations.include? resource

        relations << resource
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

        case node['type']
          when 'personal'
            agent.rdf_types << (RDF::FOAF.to_uri / 'Person').to_s
            agent.rdf_types << 'http://dbpedia.org/ontology/Person'
            agent.rdf_types << 'http://schema.org/Person'
          when 'corporate'
            agent.rdf_types << (RDF::FOAF.to_uri / 'Organization').to_s
            agent.rdf_types << 'http://dbpedia.org/ontology/Organisation'
            agent.rdf_types << 'http://schema.org/Organization'
        end

        next if agent.nil? or agents.include? agent or agent_ids.include? agent.id

        agents << agent
      end

      agents
    end

    def map_concepts(node_set, opts={})
      concepts = []
      concept_ids = @resource.concepts.map(&:id)

      node_set.each do |node|
        # in MODS, each subject access point is usually composed of multiple
        # ordered sub-elements; so that's what we process for hierarchy
        # see: http://www.loc.gov/standards/mods/userguide/subject.html

        current = nil

        node.children.each do |subnode| # xpath('./text() | ./*')
          next if subnode.text.strip.empty?

          case subnode.name
            when 'NEVER MATCH'
#            when 'name'       # Agent
#            when 'titleInfo'  # Resource
            else
              # NB: the :hiddenLabel xpath is overkill, but required for uniqueness
              mapping = opts[:skos] || {
                  :prefLabel  => '.',
                  :hiddenLabel => 'preceding-sibling::*'
              }

              skos = map_xpath subnode, mapping
              next if skos.values.flatten.empty?

              skos[:broader] = [current.id] unless current.nil?

              concept = Concept.find_or_create_by(:skos => skos)

              if 'geographic' == subnode.name
                concept.rdf_types << 'http://dbpedia.org/ontology/Place'
                concept.rdf_types << 'http://schema.org/Place'
              end
          end

          unless current.nil?
            current.skos.narrower ||= []
            current.skos.narrower << concept.id unless current.skos.narrower.include? concept.id

            current.children << concept
            current.save
          end

          current = concept
        end

        next if current.nil? or concepts.include? current or concept_ids.include? current.id

        concepts << current
      end

      concepts
    end

  end

end