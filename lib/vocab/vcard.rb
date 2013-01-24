##
# VCard vocabulary
#
# @see http://semanticweb.org/wiki/HCard
# @see http://microformats.org/wiki/hcard

module Vocab

  class VCard < RDF::Vocabulary("http://www.w3.org/2006/vcard/ns#")
    property :fn
    property :'family-name'
    property :'given-name'
    property :'additional-name'
    property :'honorific-prefix'
    property :'honorific-suffix'
    property :'post-office-box'
    property :'extended-address'
    property :'street-address'
    property :locality
    property :region
    property :'postal-code'
    property :'country-name'
    property :type
    property :value
    property :agent
    property :bday
    property :category
    property :class
    property :email
    property :geo
    property :latitude
    property :longitude
    property :key
    property :label
    property :logo
    property :mailer
    property :nickname
    property :note
    property :'organization-name'
    property :'organization-unit'
    property :photo
    property :rev
    property :role
    property :'sort-string'
    property :sound
    property :tel
    property :title
    property :tz
    property :uid
    property :url

    def self.aliases
      # camelCase aliases
      map = {:'family-name' => :familyName,
             :'given-name' => :givenName,
             :'additional-name' => :additionalName,
             :'honorific-prefix' => :honorificPrefix,
             :'honorific-suffix' => :honorificSuffix,
             :'post-office-box' => :postOfficeBox,
             :'extended-address' => :extendedAddress,
             :'street-address' => :streetAddress,
             :'postal-code' => :postalCode,
             :'country-name' => :countryName,
             :'organization-name' => :organizationName,
             :'organization-unit' => :organizationUnit,
             :'sort-string' => :sortString
      }
    end
  end

end