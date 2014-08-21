##
# DPLA Metadata Application Profile
#
# @see http://dp.la/info/schema/

require 'rdf'

module RDF

  class DPLA < RDF::StrictVocabulary("http://dp.la/about/map/")
    # Class definitions
    property :Place, :label => 'Place', :comment =>
     %(DPLA is currently reviewing methods for represtenting geospatial information in the MAP.  Please see the DPLA MAP documentation, Appendix A for alternative representations using the GeoNames Ontology. 
     At this time we have decided not to establish any formal relationships between dpla:Place and other spatial classes.)
    property :SourceResource, :label => 'SourceResource', :comment =>
     %(This class is a subclass of &quot;edm:ProvidedCHO,&quot; which comprises the source resources [in EDM called &quot;cultural heritage objects&quot;] about which DPLA collects descriptions. It is here that attributes of source resources are located, not the digital representations of them.)

    # Property definitions
    property :city, :label => 'city', :comment =>
     %(Name of a city. )
    property :country, :label => 'country', :comment =>
     %(ISO 3166-1 code for a country.)
    property :county, :label => 'county', :comment =>
     %(Name of a county.)
    property :region, :label => 'region', :comment =>
     %(Name of a region.)
    property :sourceRecord, :label => 'DPLA Source Record', :comment =>
     %(Complete original record)
    property :state, :label => 'state', :comment =>
     %(ISO 3166-2 code for a state or territory.)
    property :dataProvider, :label => 'dataProvider', :comment =>
     %(Europeana will generalize the Eurpeana Data Provider to Data Provider in an upcoming release.)
    property :intermediateProvider, :label => 'intermediateProvider', :comment =>
     %()
    property :provider, :label => 'provider', :comment =>
     %(The service or content hub providing access to the Data Provider&apos;s content (may contain the same value as Data Provider).)
    property :stateLocatedIn, :label => 'stateLocatedIn', :comment =>
     %(Name of the state in which the Data Provider is based, or United States in the case of US-wide)
  end
  
end