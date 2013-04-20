module Mapper

  class Mods < Mapper

    def self.content_types
      ['application/mods+xml']
    end

    def perform(file_id)
      @file = Mongoid::GridFS.get(file_id)

      case @file.content_type
        when 'application/mods+xml'
          parse_xml(@file.data)
        else
          raise ArgumentError, "Unsupported content type : #{@file.content_type}"
      end

    end

    # TODO: abstract to generic mapping module/class
    def map_xpath(xml_node, hash)
      mapped = {}

      hash.each do |symbol, xpath|
        nodes = []
        xml_node.xpath(xpath).each do |node|
          # include all whitespace between nodes
          text = node.xpath('descendant-or-self::text()').to_a.join(' ')

          # decode HTML entities
          text = CGI.unescapeHTML(text)

          # collapse whitespace to single spaces
          nodes << text.gsub(/(\s|\u00A0)+/, ' ').strip
        end
        mapped[symbol] = nodes.uniq unless nodes.empty?
      end

      mapped
    end

    # TODO: make this a method on parent class
    def parse_xml(xml)
      # parse XML into records using XPath
      records = Nokogiri::XML(xml).remove_namespaces!.xpath('//mods') # TODO: smarter namespace handling

      records.each do |record|
        map_xml(record) # Nokogiri::XML::Element
      end
    end

    def map_xml(xml_element)
      resource = map_mods(Resource.new, xml_element)
    end

    def map_mods(resource, node)
      # TODO: make sure this works as expected
      @@mapping ||= Mapping.find_by(:content_type => 'application/mods+xml') || Mapping.with(:database => :ladder).find_by(:content_type => 'application/mods+xml')

      # map MODS elements to embedded vocab
      vocabs = map_vocabs(node)
      return if vocabs.values.map(&:values).flatten.empty? # FIXME: make recursive flatten
      resource.vocabs = vocabs

      # map encoded agents to related Agent models
      @@mapping.agents.each do |mapping|
        map_agents(resource, node, mapping)
      end

      # map encoded concepts to related Concept models
      @@mapping.concepts.each do |mapping|
        map_concepts(resource, node, mapping)
      end

      # map related Resources as tree hierarchy
      # @see: http://www.loc.gov/standards/mods/userguide/relateditem.html
      @@mapping.resources.each do |mapping|
        map_relations(resource, node, mapping)
      end

      # save mapped resources
      resource.parent.save if resource.parent_id
      resource.save

      resource
    end

    def map_vocabs(node)
      vocabs = {}

      @@mapping.vocabs.each do |name, mapping|
        vocabs[name] = map_xpath(node, mapping)
      end

      vocabs
    end

    def map_relations(resource, node, opts)
      relations = []

      node.xpath(opts[:xpath]).each do |subnode|
        # create/map related resource
        vocabs = map_vocabs(subnode)

        next if vocabs.values.map(&:values).flatten.empty?

        # recursively map related resources
        rel_resource = Resource.find_or_create_by(vocabs)

        rel_resource = map_mods(rel_resource, subnode)
        # rel_resource.groups = resource.groups

        next if rel_resource.nil? or relations.include? rel_resource

        relations << rel_resource
      end

      unless relations.empty?
        if opts[:relation]
          vocab = opts[:relation].keys.first
          field = opts[:relation].values.first

          # set the target field value if it's provided
          resource.send(vocab).send("#{field}=", relations.map(&:id))
        end

        if opts[:inverse]
          vocab = opts[:inverse].keys.first
          field = opts[:inverse].values.first

          relations.each do |relation|
            # set the inverse field value if it's provided
            relation.send(vocab).send("#{field}=", [resource.id])
          end
        end

        if opts[:parent]
          # if we are parenting, assign the relation as the resource's parent
          resource.parent = relations.first

        elsif opts[:siblings]
          # try to assign relations as siblings if possible
          if resource.root? then resource.children << relations
          else resource.parent.children << relations
          end

        else
          # otherwise assign relations as the resource's children (default)
          resource.children << relations
        end

      end
    end

    def map_agents(resource, node, opts)
      agents = []
      agent_ids = resource.agents.map(&:id)

      mapping = opts[:vocabs]

      node.xpath(opts[:xpath]).each do |subnode|
        mapped = {}

        mapped[:foaf] = map_xpath subnode, mapping[:foaf]
        next if mapped[:foaf].values.flatten.empty?

        case subnode['type']
          when 'personal'
            mapped[:rdf_types] = {:dbpedia => [:Person],
                                  :rdafrbr => [:Person],
                                  :schema => [:Person],
                                  :foaf => [:Person]}
          when 'corporate'
            mapped[:rdf_types] = {:rdafrbr => [:CorporateBody],
                                  :dbpedia => [:Organisation],
                                  :schema => [:Organization],
                                  :foaf => [:Organization]}
        end

        agent = Agent.find_or_create_by(mapped)

        next if agent.nil? or agent_ids.include? agent.id or agents.include? agent

        agents << agent
      end

      unless agents.empty?
        if opts[:relation]
          vocab = opts[:relation].keys.first
          field = opts[:relation].values.first

          # set the target field value if it's provided
          resource.send(vocab).send("#{field}=", agents.map(&:id))
        end

        resource.agents << agents
      end
    end

    def map_concepts(resource, node, opts)
      concepts = []
      concept_ids = resource.concepts.map(&:id)

      node.xpath(opts[:xpath]).each do |subnode|
        # in MODS, each subject access point is usually composed of multiple
        # ordered sub-elements; so that's what we process for hierarchy
        # see: http://www.loc.gov/standards/mods/userguide/subject.html
        current = nil

        subnode.children.each do |subsubnode| # xpath('./text() | ./*')
          next if subsubnode.text.strip.empty?

          case subsubnode.name
            when 'NEVER MATCH'
#            when 'name'       # Agent
#            when 'titleInfo'  # Resource
            else
              mapped = {}

              # NB: the :hiddenLabel xpath is overkill, but required for uniqueness
              mapping = opts[:vocabs]

              mapped[:skos] = map_xpath subsubnode, mapping[:skos]
              next if mapped[:skos].values.flatten.empty?

              mapped[:skos][:broader] = [current.id] unless current.nil?

              if 'geographic' == subsubnode.name
                mapped[:rdf_types] = {:dbpedia => [:Place],
                                      :rdafrbr => [:Place],
                                      :schema => [:Place]}
              end

              concept = Concept.find_or_create_by(mapped)
          end

          unless current.nil?
            current.skos.narrower ||= []
            current.skos.narrower << concept.id unless current.skos.narrower.include? concept.id

            current.children << concept
            current.save
          end

          current = concept
        end

        next if current.nil? or concept_ids.include? current.id or concepts.include? current

        concepts << current
      end

      unless concepts.empty?
        if opts[:relation]
          vocab = opts[:relation].keys.first
          field = opts[:relation].values.first

          # set the target field value if it's provided
          resource.send(vocab).send("#{field}=", concepts.map(&:id))
        end

        resource.concepts << concepts
      end
    end

  end

end