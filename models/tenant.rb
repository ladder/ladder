class Tenant
  include Mongoid::Document

  field :email, type: String
  field :api_key, type: String
  
  # TODO: should we use a properties hash or explicit :models, :mappings fields?
  field :properties, type: Hash, default: {
    # FIXME: TEMPORARY FOR DEBUGGING
    models: [
      { name: 'Resource', vocabs: ['RDF::DC', 'RDF::MODS'], types: ['dc:BibliographicResource', 'mods:ModsResource'] },
      { name: 'Concept',  vocabs: ['RDF::SKOS', 'RDF::MADS'], types: ['skos:Concept', 'mads:Concept'] },
      { name: 'Agent',    vocabs: ['RDF::FOAF', 'RDF::VCARD'], types: ['foaf:Agent', 'vcard:Agent'] },
    ],
    mappings: [
      { content_type: 'application/mods+xml',
        objects: {
          _b0: {
            _model: 'Resource',
            _types: ['schema:CreativeWork'],
            dc: {
              DDC: ['subject[@authority="ddc"]', :_b1],
              LCC: ['subject[@authority="lcc"]', :_b2],
              LCSH: ['subject[@authority="lcsh"]', :_b3],
              RVM: ['subject[@authority="rvm"]', :_b4],
              abstract: 'abstract',
              alternative: 'titleInfo[@type = "alternative"]',
              contributor: ['name[not(@usage="primary")]', :_b5],
              created: 'originInfo/dateCreated',
              creator: ['name[@usage="primary"]', :_b6],
              extent: 'physicalDescription/extent',
              format: 'physicalDescription/form[not(@authority = "marcsmd")]',
              hasFormat: ['relatedItem[@type="otherFormat"]', :_b7],
              hasPart: ['relatedItem[@type="constituent"]', :_b8],
              hasVersion: ['relatedItem[@type="otherVersion"]', :_b9],
              identifier: 'identifier[not(@type) or @type="local"]',
              isPartOf: ['relatedItem[@type="host" or @type="series"][1]', :_b10],
              isReferencedBy: ['relatedItem[@type="isReferencedBy"]', :_b11],
              issued: 'originInfo/dateIssued',
              language: 'language/languageTerm',
              medium: 'physicalDescription/form[@authority = "marcsmd"]',
              publisher: ['originInfo/publisher', :_b12],
              references: ['relatedItem[@type="references"]', :_b13],
              relation: ['relatedItem[not(@type)]', :_b14],
              spatial: ['subject/geographicCode', :_b15],
              subject: ['subject[not(@authority="lcsh") and not(geographicCode)]', :_b16],
              tableOfContents: 'tableOfContents',
              title: 'titleInfo[not(@type = "alternative")]',
            },
            mods: {
              accessCondition: 'accessCondition',
              frequency: 'originInfo/frequency',
              genre: 'genre',
              issuance: 'originInfo/issuance',
              locationOfResource: 'location',
              note: 'note',
            }
          },
          _b1: {
            _model: 'Concept',
            skos: {
              hiddenLabel: 'preceding-sibling::*',
              prefLabel: '.'
            }
          },
          _b2: {
            _model: 'Concept',
            skos: {
              hiddenLabel: 'preceding-sibling::*',
              prefLabel: '.'
            }
          },
          _b3: {
            _model: 'Concept',
            skos: {
              hiddenLabel: 'preceding-sibling::*',
              prefLabel: '.'
            }
          },
          _b4: {
            _model: 'Concept',
            skos: {
              hiddenLabel: 'preceding-sibling::*',
              prefLabel: '.'
            }
          },
          _b5: {
            _model: 'Agent',
            foaf: {
              birthday: 'namePart[@type = "date"]',
              name: 'namePart[not(@type)] | displayForm',
              publications: :_b0,
              title: 'namePart[@type = "termsOfAddress"]'
            }
          },
          _b6: {
            _model: 'Agent',
            foaf: {
              birthday: 'namePart[@type = "date"]',
              name: 'namePart[not(@type)] | displayForm',
              publications: :_b0,
              title: 'namePart[@type = "termsOfAddress"]'
            }
          },
          _b7: {
            _model: 'Resource',
            dc: {
              isFormatOf: :_b0
            }
          },
          _b8: {
            _model: 'Resource',
            dc: {
              isPartOf: :_b0
            }
          },
          _b9: {
            _model: 'Resource',
            dc: {
              isVersionOf: :_b0
            }
          },
          _b10: {
            _model: 'Resource',
            dc: {
              hasPart: :_b0
            }
          },
          _b11: {
            _model: 'Resource',
            dc: {
              references: :_b0
            }
          },
          _b12: {
            _model: 'Agent',
            foaf: {
              name: '.',
              publications: :_b0
            }
          },
          _b13: {
            _model: 'Resource',
            dc: {
              isReferencedBy: :_b0
            }
          },
          _b14: {
            _model: 'Resource',
            dc: {
              relation: :_b0
            }
          },
          _b15: {
            _model: 'Concept',
            skos: {
              hiddenLabel: 'preceding-sibling::*',
              prefLabel: '.'
            }
          },
          _b16: {
            _model: 'Concept',
            skos: {
              hiddenLabel: 'preceding-sibling::*',
              prefLabel: '.'
            }
          }
        }
      }
    ]
  }

  after_initialize :generate_api_key

  after_find :define_models
  after_create :define_models

  validates_presence_of :email, :api_key

  store_in database: 'ladder'

  def generate_api_key
    # API key is a 32-character random Hex string
    self.api_key ||= SecureRandom.hex
  end
  
  # TODO: handle model removal
  def define_models
    self.properties.symbolize_keys!
    return unless self.properties[:models] and self.properties[:models].is_a? Array
    
    self.properties[:models].map do |model|
      klass = Ladder::RDF.model model.merge module: "L#{self.id}"
      klass.create unless klass.exists?
      klass
    end
  end

end