module Mapping

  class MODS

    # TODO: abstract to generic mapping module/class
    def map_xpath(xml_node, hash)
      mapped = {}

      hash.each do |symbol, xpath|
        nodes = []
        xml_node.xpath(xpath).each do |node|
          # include all whitespace between nodes, but collapse to single spaces
          nodes << node.to_xml.gsub(/<[^>]*>/ui,'').gsub(/(\s|\u00A0)+/, ' ').strip
        end
        mapped[symbol] = nodes.uniq unless nodes.empty?
      end

      mapped
    end

    def map(resource, node)
      # make resource accessible to other methods
      @resource = resource
      @node = node

      # map MODS elements to embedded vocab
      if resource.vocabs.empty?
        vocabs = map_vocabs(node)
        return if vocabs.values.map(&:values).flatten.empty?
        resource.vocabs = vocabs
      end

      # map encoded agents to related Agent models
      map_agents('name[@usage="primary"]',      {:relation => {:dcterms => :creator}})
      map_agents('name[not(@usage="primary")]', {:relation => {:dcterms => :contributor}})
      map_agents('originInfo/publisher',        {:relation => {:dcterms => :publisher},
                                                 :mapping  => {:foaf => {:name => '.'}}})

      # map encoded concepts to related Concept models
      map_concepts('subject/geographicCode',               {:relation => {:dcterms => :spatial}})
      map_concepts('subject[not(@authority="lcsh")
                    and not(geographicCode)]',             {:relation => {:dcterms => :subject}})
      map_concepts('subject[@authority="lcsh"]',           {:relation => {:dcterms => :LCSH}})
      map_concepts('subject[@authority="rvm"]',            {:relation => {:dcterms => :RVM}})
      map_concepts('classification[@authority="ddc"]',     {:relation => {:dcterms => :DDC}})
      map_concepts('classification[@authority="lcc"]',     {:relation => {:dcterms => :LCC}})

      # map related Resources as tree hierarchy
      # @see: http://www.loc.gov/standards/mods/userguide/relateditem.html

      # limit to one relation to avoid a multi-parent situation
      map_relations('relatedItem[@type="host"
                     or @type="series"][1]',               {:parent   => true,
                                                            :relation => {:dcterms => :isPartOf},
                                                            :inverse  => {:dcterms => :hasPart}})
      map_relations('relatedItem[@type="constituent"]',    {:relation => {:dcterms => :hasPart},
                                                            :inverse  => {:dcterms => :isPartOf}})
      map_relations('relatedItem[@type="otherVersion"]',   {:siblings => true,
                                                            :relation => {:dcterms => :hasVersion},
                                                            :inverse  => {:dcterms => :isVersionOf}})
      map_relations('relatedItem[@type="otherFormat"]',    {:siblings => true,
                                                            :relation => {:dcterms => :hasFormat},
                                                            :inverse  => {:dcterms => :isFormatOf}})
      map_relations('relatedItem[@type="isReferencedBy"]', {:siblings => true,
                                                            :relation => {:dcterms => :isReferencedBy},
                                                            :inverse  => {:dcterms => :references}})
      map_relations('relatedItem[@type="references"]',     {:siblings => true,
                                                            :relation => {:dcterms => :references},
                                                            :inverse  => {:dcterms => :isReferencedBy}})
      # NB: these relationships are poorly defined
      map_relations('relatedItem[not(@type)]')

      # TODO: find an appropriate relation type for these
      map_relations('relatedItem[@type="original"
                     or @type="preceding"
                     or @type="succeeding"
                     or @type="reviewOf"]',                {:siblings => true})

      # save mapped resources
      @resource.parent.save if @resource.parent_id
      @resource.save

      @resource
    end

    def map_vocabs(node)
      vocabs = {}

      dcterms = map_xpath node, {
          # descriptive elements
          :title         => 'titleInfo[not(@type = "alternative")]',
          :alternative   => 'titleInfo[@type = "alternative"]',
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

          # TODO: add <note> etc.
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

    def map_relations(xpath, opts={})
      relations = []

      @node.xpath(xpath).each do |node|
        # create/map related resource
        vocabs = map_vocabs(node)

        next if vocabs.values.map(&:values).flatten.empty?

        # recursively map related resources
        resource = Resource.find_or_create_by(vocabs)

        resource = Mapping::MODS.new.map(resource, node)
        resource.groups = @resource.groups

        next if resource.nil? or relations.include? resource

        relations << resource
      end

      unless relations.empty?
        if opts[:relation]
          vocab = opts[:relation].keys.first
          field = opts[:relation].values.first

          # set the target field value if it's provided
          @resource.send("#{vocab}=", @resource.class.vocabs[vocab].new) if @resource.send(vocab).nil?
          @resource.send(vocab).send("#{field}=", relations.map(&:id))
        end

        if opts[:inverse]
          vocab = opts[:inverse].keys.first
          field = opts[:inverse].values.first

          relations.each do |relation|
            # set the inverse field value if it's provided
            relation.send("#{vocab}=", relation.class.vocabs[vocab].new) if relation.send(vocab).nil?
            relation.send(vocab).send("#{field}=", [@resource.id])
          end
        end

        if opts[:parent]
          # if we are parenting, assign the relation as the resource's parent
          @resource.parent = relations.first

        elsif opts[:siblings]
          # try to assign relations as siblings if possible
          if @resource.root? then @resource.children << relations
          else @resource.parent.children << relations
          end

        else
          # otherwise assign relations as the resource's children (default)
          @resource.children << relations
        end

      end
    end

    def map_agents(xpath, opts={})
      agents = []
      agent_ids = @resource.agents.map(&:id)

      mapping = opts[:mapping] || { :foaf => {
          :name     => 'namePart[not(@type)] | displayForm',
          :birthday => 'namePart[@type = "date"]',
          :title    => 'namePart[@type = "termsOfAddress"]',
        }
      }

      @node.xpath(xpath).each do |node|
        mapped = {}

        mapped[:foaf] = map_xpath node, mapping[:foaf]
        next if mapped[:foaf].values.flatten.empty?

        case node['type']
          when 'personal'
            mapped[:rdf_types] = [[:foaf, :Person],
                                  [:dbpedia, :Person],
                                  [:schema, :Person]]
          when 'corporate'
            mapped[:rdf_types] = [[:foaf, :Organization],
                                  [:dbpedia, :Organisation],
                                  [:schema, :Organization]]
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
          @resource.send("#{vocab}=", @resource.class.vocabs[vocab].new) if @resource.send(vocab).nil?
          @resource.send(vocab).send("#{field}=", agents.map(&:id))
        end

        @resource.agents << agents
      end
    end

    def map_concepts(xpath, opts={})
      concepts = []
      concept_ids = @resource.concepts.map(&:id)

      @node.xpath(xpath).each do |node|
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
              mapped = {}

              # NB: the :hiddenLabel xpath is overkill, but required for uniqueness
              mapping = opts[:mapping] || { :skos => {
                  :prefLabel  => '.',
                  :hiddenLabel => 'preceding-sibling::*'
                }
              }

              mapped[:skos] = map_xpath subnode, mapping[:skos]
              next if mapped[:skos].values.flatten.empty?

              mapped[:skos][:broader] = [current.id] unless current.nil?

              if 'geographic' == subnode.name
                mapped[:rdf_types] = [[:dbpedia, :Place],
                                      [:schema, :Place]]
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
          @resource.send("#{vocab}=", @resource.class.vocabs[vocab].new) if @resource.send(vocab).nil?
          @resource.send(vocab).send("#{field}=", concepts.map(&:id))
        end

        @resource.concepts << concepts
      end
    end

  end

end