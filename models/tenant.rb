class Tenant
  include Mongoid::Document

  field :email, type: String
  field :api_key, type: String
  field :database, type: String
  field :properties, type: Hash, default: {
    # FIXME: TEMPORARY FOR DEBUGGING
    models: [
      { name: 'Resource', vocabs: ['RDF::DC', 'RDF::MODS'], types: ['RDF::DC.BibliographicResource', 'RDF::MODS.ModsResource'] },
      { name: 'Concept',  vocabs: ['RDF::SKOS', 'RDF::MADS'], types: ['RDF::SKOS.Concept', 'RDF::MADS.Concept'] },
      { name: 'Agent',    vocabs: ['RDF::FOAF', 'RDF::VCARD'], types: ['RDF::FOAF.Agent', 'RDF::VCARD.Agent'] },
    ],
    mappings: [
      { content_type: 'application/mods+xml', model: 'Resource',# types: ['RDF::BIBO.Document', 'RDF::DC.BibliographicResource'],
        properties: [
          # These map to RDF property / XPath pairs
          ['RDF::DC.title', 'titleInfo[not(@type = "alternative")]'],
          ['RDF::MODS.note', 'note'],
        ],
        mappings: [
          # These map to embedded/related Mappings
          ['RDF::DC.hasPart', 'relatedItem[@type="constituent"]', {
            model: 'Resource', properties: [
              'RDF::DC.isPartOf', '' # FIXME: THIS HAS TO POINT AT THE ROOT MAPPING
            ]
          }],
          ['RDF::DC.publisher', 'originInfo/publisher'],
          ['RDF::DC.subject', 'subject[not(@authority="lcsh") and not(geographicCode)]'],
        ]
      }
    ]
  }

  after_initialize :generate_api_key
  after_initialize :set_database

  after_find :define_models
  after_create :define_models

  validates_presence_of :email, :api_key, :database

  store_in database: 'ladder'

  def generate_api_key
    # API key is a 32-character random Hex string
    self.api_key ||= SecureRandom.hex
  end

  def set_database
    address = Mail::Address.new(self.email)
    self.database ||= address.domain unless address.domain.nil?
  end
  
  # TODO: handle model removal?
  def define_models
    return unless self.properties[:models] and self.properties[:models].is_a? Array
    
    self.properties[:models].map do |model|
      Ladder::RDF.model model.merge module: "L#{self.id}"
    end
  end

end