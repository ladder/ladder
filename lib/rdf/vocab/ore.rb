##
# Open Archives Initiative Object Reuse and Exchange (OAI-ORE)
#
# @see http://www.openarchives.org/ore/1.0/vocabulary

require 'rdf'

module RDF

  class ORE < RDF::StrictVocabulary("http://www.openarchives.org/ore/terms/")
    # Class definitions
    property :Aggregation, :label => 'Aggregation', :comment =>
     %(A set of related resources (Aggregated Resources), grouped together such that the set can be treated as a single resource. This is the entity described within the ORE interoperability framework by a Resource Map.)
    property :AggregatedResource, :label => 'Aggregated Resource', :comment =>
     %(A resource which is included in an Aggregation. Note that asserting that a resource is a member of the class of Aggregated Resources does not imply anything other than that it is aggregated by at least one Aggregation.)
    property :Proxy, :label => 'Proxy', :comment =>
     %(A Proxy represents an Aggregated Resource as it exists in a specific Aggregation. All assertions made about an entity are globally true, not only within the context of the Aggregation. As such, in order to make assertions which are only true of a resource as it exists in an Aggregation, a Proxy object is required. For example, one might want to cite an article as it appears in a specific journal, or assign aggregation-specific metadata to a Resource.)
    property :ResourceMap, :label => 'Resource Map', :comment =>
     %(A description of an Aggregation according to the OAI-ORE data model. Resource Maps are serialised to a machine readable format according to the implementation guidelines.)

    # Property definitions
    property :aggregates, :label => 'Aggregates', :comment =>
     %(Aggregations, by definition, aggregate resources. The ore:aggregates relationship expresses that the object resource is a member of the set of Aggregated Resources of the subject (the Aggregation). This relationship between the Aggregation and its Aggregated Resources is thus more specific than a simple part/whole relationship, as expressed by dcterms:hasPart for example.)
    property :isAggregatedBy, :label => 'Is Aggregated By', :comment =>
     %(The inverse relationship of ore:aggregates, ore:isAggregatedBy asserts that an Aggregated Resource is aggregated by an Aggregation.)
    property :describes, :label => 'Describes', :comment =>
     %(This relationship asserts that the subject (a Resource Map) describes the object (an Aggregation).)
    property :isDescribedBy, :label => 'Is Described By', :comment =>
     %(The inverse relationship of ore:describes, in this case the object of the relationship is the Resource Map and the subject is the Aggregation which it describes.)
    property :lineage, :label => 'Lineage', :comment =>
     %(ore:lineage is a relationship between two Proxy objects, both of which MUST have the same Resource for which they are proxies. The meaning is that the Resource for which the subject of the relationship is a Proxy was discovered in the Aggregation in which the object Proxy's resource is aggregated.)
    property :proxyFor, :label => 'Proxy For', :comment =>
     %(Proxy objects are used to represent a Resource as it is aggregated in a particular Aggregation. The ore:proxyFor relationship is used to link the proxy to the Aggregated Resource it is a proxy for. The subject of the relationship is a Proxy object, and the object of the relationship is the Aggregated Resource.)
    property :proxyIn, :label => 'Proxy In', :comment =>
     %(Proxy objects must link to the Aggregation in which the resource being proxied is aggregated. The ore:proxyIn relationship is used for this purpose. The subject of the relationship is a Proxy object, and the object of the relationship is the Aggregation.)
    property :similarTo, :label => 'Similar To', :comment =>
     %(The subject of this relationship MUST be an Aggregation.  This Aggregation should be considered an expression within the ORE context of the object of the relationship, as it is broadly equivalent to the resource. For example, the Aggregation may consist of the resources which, together, make up a journal article which has a DOI assigned to it. The Aggregation is not the article to which the DOI was assigned, but is a representation of it in some manner.)
  end

end