class Tenant
  include Mongoid::Document

  field :api_key, type: String
  field :email, type: String
  field :database, type: String
  field :properties, type: Hash, default: {
    models: [
      {name: 'Resource', vocabs: ['RDF::DC', 'RDF::MODS']},
      {name: 'Concept',  vocabs: ['RDF::SKOS']},
      {name: 'Agent',    vocabs: ['RDF::FOAF']},
    ]
  }

  after_initialize :generate_api_key
  after_initialize :set_database

  validates_presence_of :api_key
  validates_presence_of :email
  validates_presence_of :database

  store_in database: 'ladder', collection: 'tenants'

  def generate_api_key
    # API key is a 32-character random Hex string
    self.api_key ||= SecureRandom.hex
  end

  def set_database
    address = Mail::Address.new(self.email)
    self.database ||= address.domain unless address.domain.nil?
  end

end