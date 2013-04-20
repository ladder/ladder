class Ladder < Padrino::Application
  register Padrino::Rendering
  register Padrino::Helpers
#  register Kaminari::Helpers::SinatraHelpers

  configure do
    mime_type :marc, ['application/marc', 'application/marc+xml', 'application/marc+json']
    mime_type :mods, 'application/mods+xml'
  end

  configure :development do
    disable :asset_stamp

    use BetterErrors::Middleware
    BetterErrors.application_root = PADRINO_ROOT
  end

  configure :production do
    register Padrino::Cache
    register Padrino::Contrib::ExceptionNotifier
    register Padrino::Mailer

    enable :caching
    disable :raise_errors
    disable :show_exceptions

    set :exceptions_from,    "errors@deliberatedata.com"
    set :exceptions_to,      "errors@deliberatedata.com"
    set :exceptions_page,    'errors/50x'
    set :exceptions_layout,  :application
    set :delivery_method, :smtp => {
      :address              => "smtp.sendgrid.net",
      :port                 => 587,
      :authentication       => :plain,
      :user_name            => ENV['SENDGRID_USERNAME'],
      :password             => ENV['SENDGRID_PASSWORD'],
      :domain               => 'heroku.com',
      :enable_starttls_auto => true
    }
  end

  use Rack::Mongoid::Middleware::IdentityMap

  Mongoid::History.tracker_class_name = :history_tracker

  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end

  def self.destroy
    # Remove existing Mongo DB
    Mongoid::Sessions.default.with(:database => Search.index_name).collections.each {|collection| collection.drop}

    # Remove existing ES index
    index_response = Search.delete

    # Send index/mapping
    self.create

    index_response
  end

  def self.create
    %w[Agent Concept Resource].each do |model|
      klass = model.classify.constantize
      klass.create_indexes
      klass.put_mapping
    end

    # TODO
    # FIXME
    # TEMPORARY: create a default MODS mapping
    mapping  = Mapping.new(:type => 'Resource')

    mapping.vocabs = {
        :dcterms => {
            # descriptive elements
            :title              => 'titleInfo[not(@type = "alternative")]',
            :alternative        => 'titleInfo[@type = "alternative"]',
            :created            => 'originInfo/dateCreated',
            :issued             => 'originInfo/dateIssued',
            :format             => 'physicalDescription/form[not(@authority = "marcsmd")]',
            :medium             => 'physicalDescription/form[@authority = "marcsmd"]',
            :extent             => 'physicalDescription/extent',
            :language           => 'language/languageTerm',

            # dereferenceable identifiers
            :identifier         => 'identifier[not(@type) or @type="local"]',

            # indexable textual content
            :abstract           => 'abstract',
            :tableOfContents    => 'tableOfContents',
        },
        :prism => {
            # dereferenceable identifiers
            :doi                => 'identifier[@type = "doi" and not(@invalid)]',
            :isbn               => 'identifier[@type = "isbn" and not(@invalid)]',
            :issn               => 'identifier[@type = "issn" and not(@invalid)]',

            :edition            => 'originInfo/edition',
            :issueIdentifier    => 'identifier[@type = "issue-number" or @type = "issue number"]',
        },
        :bibo => {
            # dereferenceable identifiers
            :lccn               => 'identifier[@type = "lccn" and not(@invalid)]',
            :oclcnum            => 'identifier[@type = "oclc" and not(@invalid)]',
            :upc                => 'identifier[@type = "upc" and not(@invalid)]',
            :uri                => 'identifier[@type = "uri" and not(@invalid)]',
        },
        :mods => {
            :accessCondition    => 'accessCondition',
            :frequency          => 'originInfo/frequency',
            :genre              => 'genre',
            :issuance           => 'originInfo/issuance',
            :locationOfResource => 'location',
            :note               => 'note',
        },
    }

    mapping.agents = [
        {:xpath => 'name[@usage="primary"]',
         :relation => {:dcterms => :creator},
         :vocabs => {
             :foaf => {
                 :name     => 'namePart[not(@type)] | displayForm',
                 :birthday => 'namePart[@type = "date"]',
                 :title    => 'namePart[@type = "termsOfAddress"]',
             }
         }
        },
        {:xpath => 'name[not(@usage="primary")]',
         :relation => {:dcterms => :contributor},
         :vocabs => {
             :foaf => {
                 :name     => 'namePart[not(@type)] | displayForm',
                 :birthday => 'namePart[@type = "date"]',
                 :title    => 'namePart[@type = "termsOfAddress"]',
             }
         }
        },
        {:xpath => 'originInfo/publisher',
         :relation => {:dcterms => :publisher},
         :vocabs  => {
             :foaf => {:name => '.'}}
        },
    ]

    mapping.concepts = [
        {:xpath => 'subject/geographicCode',
         :relation => {:dcterms => :spatial},
         :vocabs => {
             :skos => {
                 :prefLabel  => '.',
                 :hiddenLabel => 'preceding-sibling::*'
             }}
        },
        {:xpath => 'subject[not(@authority="lcsh") and not(geographicCode)]',
         :relation => {:dcterms => :subject},
         :vocabs => {
             :skos => {
                 :prefLabel  => '.',
                 :hiddenLabel => 'preceding-sibling::*'
             }
         }
        },
        {:xpath => 'subject[@authority="lcsh"]',
         :relation => {:dcterms => :LCSH},
         :vocabs => {
             :skos => {
                 :prefLabel  => '.',
                 :hiddenLabel => 'preceding-sibling::*'
             }
         }
        },
        {:xpath => 'subject[@authority="rvm"]',
         :relation => {:dcterms => :RVM},
         :vocabs => {
             :skos => {
                 :prefLabel  => '.',
                 :hiddenLabel => 'preceding-sibling::*'
             }
         }
        },
        {:xpath => 'classification[@authority="ddc"]',
         :relation => {:dcterms => :DDC},
         :vocabs => {
             :skos => {
                 :prefLabel  => '.',
                 :hiddenLabel => 'preceding-sibling::*'
             }
         }
        },
        {:xpath => 'classification[@authority="lcc"]',
         :relation => {:dcterms => :LCC},
         :vocabs => {
             :skos => {
                 :prefLabel  => '.',
                 :hiddenLabel => 'preceding-sibling::*'
             }
         }
        },
    ]

    mapping.resources = [
        # NB: limit to one relation to avoid a multi-parent situation
        {:xpath => 'relatedItem[@type="host" or @type="series"][1]',
         :relation => {:dcterms => :isPartOf},
         :inverse => {:dcterms => :hasPart},
         :parent => true,
        },
        {:xpath => 'relatedItem[@type="constituent"]',
         :relation => {:dcterms => :hasPart},
         :inverse => {:dcterms => :isPartOf},
        },
        {:xpath => 'relatedItem[@type="otherVersion"]',
         :relation => {:dcterms => :hasVersion},
         :inverse => {:dcterms => :isVersionOf},
         :siblings => true,
        },
        {:xpath => 'relatedItem[@type="otherFormat"]',
         :relation => {:dcterms => :hasFormat},
         :inverse => {:dcterms => :isFormatOf},
         :siblings => true,
        },
        {:xpath => 'relatedItem[@type="isReferencedBy"]',
         :relation => {:dcterms => :isReferencedBy},
         :inverse => {:dcterms => :references},
         :siblings => true,
        },
        {:xpath => 'relatedItem[@type="references"]',
         :relation => {:dcterms => :references},
         :inverse => {:dcterms => :isReferencedBy},
         :siblings => true,
        },
        # NB: these relationships are poorly defined
        {:xpath => 'relatedItem[not(@type)]',
        },
        # TODO: find an appropriate relation type for these
        {:xpath => 'relatedItem[@type="original"
                     or @type="preceding"
                     or @type="succeeding"
                     or @type="reviewOf"]',
         :siblings => true,
        },
    ]

    mapping.save
  end
end