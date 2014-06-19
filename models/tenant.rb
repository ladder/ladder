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
      { content_type: 'application/mods+xml',
        objects: {
          # ObjectMapping
          _b0: {
            model: 'Resource',
            types: ['schema:CreativeWork'],
            statements: [
              ['dc:DDC', 'subject[@authority=\"ddc\"]', :_b1],
              ['dc:LCC', 'subject[@authority=\"lcc\"]', :_b2],
              ['dc:LCSH', 'subject[@authority=\"lcsh\"]', :_b3],
              ['dc:RVM', 'subject[@authority=\"rvm\"]', :_b4],
              ['dc:abstract', 'abstract'],
              ['dc:alternative', 'titleInfo[@type = \"alternative\"]'],
              ['dc:contributor', 'name[not(@usage=\"primary\")]', :_b5],
              ['dc:created', 'originInfo/dateCreated'],
              ['dc:creator', 'name[@usage=\"primary\"]', :_b6],
              ['dc:extent', 'physicalDescription/extent'],
              ['dc:format', 'physicalDescription/form[not(@authority = \"marcsmd\")]'],
              ['dc:hasFormat', 'relatedItem[@type=\"otherFormat\"]', :_b7],
              ['dc:hasPart', 'relatedItem[@type=\"constituent\"]', :_b8],
              ['dc:hasVersion', 'relatedItem[@type=\"otherVersion\"]', :_b9],
              ['dc:identifier', 'identifier[not(@type) or @type=\"local\"]'],
              ['dc:isPartOf', 'relatedItem[@type=\"host\" or @type=\"series\"][1]', :_b10],
              ['dc:isReferencedBy', 'relatedItem[@type=\"isReferencedBy\"]', :_b11],
              ['dc:issued', 'originInfo/dateIssued'],
              ['dc:language', 'language/languageTerm'],
              ['dc:medium', 'physicalDescription/form[@authority = \"marcsmd\"]'],
              ['dc:publisher', 'originInfo/publisher', :_b12],
              ['dc:references', 'relatedItem[@type=\"references\"]', :_b13],
              ['dc:relation', 'relatedItem[not(@type)]', :_b14],
              ['dc:spatial', 'subject/geographicCode', :_b15],
              ['dc:subject', 'subject[not(@authority=\"lcsh\") and not(geographicCode)]', :_b16],
              ['dc:tableOfContents', 'tableOfContents'],
              ['dc:title', 'titleInfo[not(@type = \"alternative\")]'],
              ['mods:accessCondition', 'accessCondition'],
              ['mods:frequency', 'originInfo/frequency'],
              ['mods:genre', 'genre'],
              ['mods:issuance', 'originInfo/issuance'],
              ['mods:locationOfResource', 'location'],
              ['mods:note', 'note'],
            ]
          },
          _b1: {
            model: 'Concept',
            statements: [
              ['skos:hiddenLabel', 'preceding-sibling::*'],
              ['skos:prefLabel', '.'],
            ]
          },
          _b2: {
            model: 'Concept',
            statements: [
              ['skos:hiddenLabel', 'preceding-sibling::*'],
              ['skos:prefLabel', '.'],
            ]
          },
          _b3: {
            model: 'Concept',
            statements: [
              ['skos:hiddenLabel', 'preceding-sibling::*'],
              ['skos:prefLabel', '.'],
            ]
          },
          _b4: {
            model: 'Concept',
            statements: [
              ['skos:hiddenLabel', 'preceding-sibling::*'],
              ['skos:prefLabel', '.'],
            ]
          },
          _b5: {
            model: 'Agent',
            statements: [
              ['foaf:birthday', 'namePart[@type = \"date\"]'],
              ['foaf:name', 'namePart[not(@type)] | displayForm'],
              ['foaf:publications', :_b0],
              ['foaf:title', 'namePart[@type = \"termsOfAddress\"]'],
            ]
          },
          _b6: {
            model: 'Agent',
            statements: [
              ['foaf:birthday', 'namePart[@type = \"date\"]'],
              ['foaf:name', 'namePart[not(@type)] | displayForm'],
              ['foaf:publications', :_b0],
              ['foaf:title', 'namePart[@type = \"termsOfAddress\"]'],
            ]
          },
          _b7: {
            model: 'Resource',
            statements: [
              ['dc:isFormatOf', :_b0],
            ]
          },
          _b8: {
            model: 'Resource',
            statements: [
              ['dc:isPartOf', :_b0],
            ]
          },
          _b9: {
            model: 'Resource',
            statements: [
              ['dc:isVersionOf', :_b0],
            ]
          },
          _b10: {
            model: 'Resource',
            statements: [
              ['dc:hasPart', :_b0],
            ]
          },
          _b11: {
            model: 'Resource',
            statements: [
              ['dc:references', :_b0],
            ]
          },
          _b12: {
            model: 'Agent',
            statements: [
              ['foaf:name', '.'],
              ['foaf:publications', :_b0],
            ]
          },
          _b13: {
            model: 'Resource',
            statements: [
              ['dc:isReferencedBy', :_b0],
            ]
          },
          _b14: {
            model: 'Resource',
            statements: [
              ['dc:relation', :_b0],
            ]
          },
          _b15: {
            model: 'Concept',
            statements: [
              ['skos:hiddenLabel', 'preceding-sibling::*'],
              ['skos:prefLabel', '.'],
            ]
          },
          _b16: {
            model: 'Concept',
            statements: [
              ['skos:hiddenLabel', 'preceding-sibling::*'],
              ['skos:prefLabel', '.'],
            ]
          }
        }
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