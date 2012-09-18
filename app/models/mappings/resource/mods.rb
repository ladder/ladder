class MODS < LadderMapping::Mapping

  def self.vocabs(node)
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

  def self.relations(xml_nodeset)
    relations = {:children => [], :siblings => [],
                 :fields => {:dcterms => {}, :bibo => {}, :prism => {}}}

    xml_nodeset.each do |node|

      # apply vocab mapping to each related resource
      vocabs = self.vocabs(node)

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

  def self.agents(xml_nodeset)
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

  def self.concepts(xml_nodeset)
    concepts = []
  end

end
