class FOAF
  include LadderModel::Embedded
  bind_to RDF::FOAF, :type => Array
  embedded_in :agent
end

class VCard
  include LadderModel::Embedded
  bind_to LadderVocab::VCard, :type => Array

  # camelCase aliases
  alias :familyName :'family-name'
  alias :givenName :'given-name'
  alias :additionalName :'additional-name'
  alias :honorificPrefix :'honorific-prefix'
  alias :honorificSuffix :'honorific-suffix'
  alias :postOfficeBox :'post-office-box'
  alias :extendedAddress :'extended-address'
  alias :streetAddress :'street-address'
  alias :postalCode :'postal-code'
  alias :countryName :'country-name'
  alias :organizationName :'organization-name'
  alias :organizationUnit :'organization-unit'
  alias :sortString :'sort-string'

  embedded_in :agent
end

class Agent
  include LadderModel::Core

  def heading
    get_first_field(['foaf.name', 'foaf.givenName', 'foaf.givenname']) || ['untitled']
  end

  # embedded RDF vocabularies
  embeds_one :foaf, class_name: "FOAF"
  embeds_one :vcard, class_name: "VCard"

  # index embedded documents
  mapping indexes :foaf, :type => 'object'
  mapping indexes :vcard, :type => 'object'

  # model relations
  has_and_belongs_to_many :resources
  has_and_belongs_to_many :concepts
end