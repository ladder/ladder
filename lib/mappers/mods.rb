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

    def map_mods(resource, node)

      # map MODS elements to embedded vocab
      vocabs = map_vocabs(node)
      return if vocabs.values.map(&:values).flatten.empty?
      resource.vocabs = vocabs

      # map encoded agents to related Agent models
      map_agents(resource, node, 'name[@usage="primary"]',      {:relation => {:dcterms => :creator}})
      map_agents(resource, node, 'name[not(@usage="primary")]', {:relation => {:dcterms => :contributor}})
      map_agents(resource, node, 'originInfo/publisher',        {:relation => {:dcterms => :publisher},
                                                                 :mapping  => {:foaf => {:name => '.'}}})

      # map encoded concepts to related Concept models
      map_concepts(resource, node, 'subject/geographicCode',               {:relation => {:dcterms => :spatial}})
      map_concepts(resource, node, 'subject[not(@authority="lcsh")
                    and not(geographicCode)]',             {:relation => {:dcterms => :subject}})
      map_concepts(resource, node, 'subject[@authority="lcsh"]',           {:relation => {:dcterms => :LCSH}})
      map_concepts(resource, node, 'subject[@authority="rvm"]',            {:relation => {:dcterms => :RVM}})
      map_concepts(resource, node, 'classification[@authority="ddc"]',     {:relation => {:dcterms => :DDC}})
      map_concepts(resource, node, 'classification[@authority="lcc"]',     {:relation => {:dcterms => :LCC}})

      # map related Resources as tree hierarchy
      # @see: http://www.loc.gov/standards/mods/userguide/relateditem.html

      # limit to one relation to avoid a multi-parent situation
      map_relations(resource, node, 'relatedItem[@type="host"
                     or @type="series"][1]',               {:parent   => true,
                                                            :relation => {:dcterms => :isPartOf},
                                                            :inverse  => {:dcterms => :hasPart}})
      map_relations(resource, node, 'relatedItem[@type="constituent"]',    {:relation => {:dcterms => :hasPart},
                                                                            :inverse  => {:dcterms => :isPartOf}})
      map_relations(resource, node, 'relatedItem[@type="otherVersion"]',   {:siblings => true,
                                                                            :relation => {:dcterms => :hasVersion},
                                                                            :inverse  => {:dcterms => :isVersionOf}})
      map_relations(resource, node, 'relatedItem[@type="otherFormat"]',    {:siblings => true,
                                                                            :relation => {:dcterms => :hasFormat},
                                                                            :inverse  => {:dcterms => :isFormatOf}})
      map_relations(resource, node, 'relatedItem[@type="isReferencedBy"]', {:siblings => true,
                                                                            :relation => {:dcterms => :isReferencedBy},
                                                                            :inverse  => {:dcterms => :references}})
      map_relations(resource, node, 'relatedItem[@type="references"]',     {:siblings => true,
                                                                            :relation => {:dcterms => :references},
                                                                            :inverse  => {:dcterms => :isReferencedBy}})
      # NB: these relationships are poorly defined
      map_relations(resource, node, 'relatedItem[not(@type)]')

      # TODO: find an appropriate relation type for these
      map_relations(resource, node, 'relatedItem[@type="original"
                     or @type="preceding"
                     or @type="succeeding"
                     or @type="reviewOf"]',                {:siblings => true})

      # save mapped resources
      resource.parent.save if resource.parent_id
      resource.save

      resource
    end

    def map_vocabs(node)
      vocabs = {}

      dcterms = map_xpath node, {
          # descriptive elements
          :title         => 'titleInfo[not(@type = "alternative")]',
          :alternative   => 'titleInfo[@type = "alternative"]',
          :created       => 'originInfo/dateCreated',
          :issued        => 'originInfo/dateIssued',
          :format        => 'physicalDescription/form[not(@authority = "marcsmd")]',
          :medium        => 'physicalDescription/form[@authority = "marcsmd"]',
          :extent        => 'physicalDescription/extent',
          :language      => 'language/languageTerm',

          # dereferenceable identifiers
          :identifier    => 'identifier[not(@type) or @type="local"]',

          # indexable textual content
          :abstract        => 'abstract',
          :tableOfContents => 'tableOfContents',
      }

      prism = map_xpath node, {
          # dereferenceable identifiers
          :doi      => 'identifier[@type = "doi" and not(@invalid)]',
          :isbn     => 'identifier[@type = "isbn" and not(@invalid)]',
          :issn     => 'identifier[@type = "issn" and not(@invalid)]',

          :edition          => 'originInfo/edition',
          :issueIdentifier  => 'identifier[@type = "issue-number" or @type = "issue number"]',
      }

      bibo = map_xpath node, {
          # dereferenceable identifiers
          :lccn     => 'identifier[@type = "lccn" and not(@invalid)]',
          :oclcnum  => 'identifier[@type = "oclc" and not(@invalid)]',
          :upc      => 'identifier[@type = "upc" and not(@invalid)]',
          :uri      => 'identifier[@type = "uri" and not(@invalid)]',
      }

      mods = map_xpath node, {
          :accessCondition    => 'accessCondition',
          :frequency          => 'originInfo/frequency',
          :genre              => 'genre',
          :issuance           => 'originInfo/issuance',
          :locationOfResource => 'location',
          :note               => 'note',
      }

      vocabs[:dcterms] = dcterms unless dcterms.empty?
      vocabs[:bibo]    = bibo    unless bibo.empty?
      vocabs[:prism]   = prism   unless prism.empty?
      vocabs[:mods]    = mods    unless mods.empty?

      vocabs
    end

    def map_relations(resource, node, xpath, opts={})
      relations = []

      node.xpath(xpath).each do |subnode|
        # create/map related resource
        vocabs = map_vocabs(subnode)

        next if vocabs.values.map(&:values).flatten.empty?

        # recursively map related resources
        rel_resource = Resource.find_or_create_by(vocabs)

        rel_resource = map_mods(rel_resource, subnode)
        #        rel_resource.groups = resource.groups

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

    def map_agents(resource, node, xpath, opts={})
      agents = []
      agent_ids = resource.agents.map(&:id)

      mapping = opts[:mapping] || { :foaf => {
          :name     => 'namePart[not(@type)] | displayForm',
          :birthday => 'namePart[@type = "date"]',
          :title    => 'namePart[@type = "termsOfAddress"]',
      }
      }

      node.xpath(xpath).each do |subnode|
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

    def map_concepts(resource, node, xpath, opts={})
      concepts = []
      concept_ids = resource.concepts.map(&:id)

      node.xpath(xpath).each do |subnode|
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
              mapping = opts[:mapping] || { :skos => {
                  :prefLabel  => '.',
                  :hiddenLabel => 'preceding-sibling::*'
              }
              }

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