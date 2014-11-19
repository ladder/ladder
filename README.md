![Ladder logo](https://github.com/mjsuhonos/ladder/blob/master/logo.png)

[![Gem Version](http://img.shields.io/gem/v/ladder.svg)](https://rubygems.org/gems/ladder) [![Build Status](https://travis-ci.org/mjsuhonos/ladder.svg)](https://travis-ci.org/mjsuhonos/ladder)

# Ladder

Ladder is a dynamic, scalable metadata framework written in Ruby using well-known components for Linked Data ([ActiveTriples](https://github.com/no-reply/ActiveTriples)/RDF.rb), persistence ([Mongoid](http://mongoid.org)/MongoDB), indexing ([ElasticSearch](http://www.elasticsearch.org)), asynchronicity ([Sidekiq](http://sidekiq.org)/Redis) and HTTP interaction ([Padrino](http://www.padrinorb.com)/Sinatra).  It is designed around the following philosophical goals:

- make it as modular as possible
- use as much commodity tooling as possible
- make it as easy to use as possible

## History

Ladder was loosely conceived over the course of several years prior to 2011.  In early 2012, Ladder began existence as an opportunity to escape from a decade of LAMP development and become familiar with Ruby.  From 2012 to late 2013, a closed prototype was built under the auspices of [Deliberate Data](http://deliberatedata.com) as a proof-of-concept to test the feasibility of the design.

From mid-2014, Ladder is being re-architected as a series of Ruby modules that can be used individually and incorporated within existing Ruby frameworks (eg. [Project Hydra](http://projecthydra.org)), or used together as a comprehensive stack.  Ladder is intended to encourage the LAM community to think less dogmatically about our established (often monolithic and/or niche) toolsets and instead embrace a broader vision of using non-LAM specific technologies.

For those interested in the historical code, the original [prototype](https://github.com/mjsuhonos/ladder/tree/prototype) branch is available, as is an [experimental](https://github.com/mjsuhonos/ladder/tree/l2) branch.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ladder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ladder

## Usage

* [Resources](#resource)
  * [Configuring Resources](#configuring-resources)
  * [Dynamic Resources](#dynamic-resources)
* [Indexing for Search](#indexing-for-search)

### Resources

Much like ActiveTriples, Resources are the core of Ladder.  Resources implement all the functionality of a Mongoid::Document and an ActiveTriples::Resource.  To add Ladder integration for your model, require 
and include the main module in your class:

```ruby
require 'ladder'

class Person
  include Ladder::Resource

  configure type: RDF::FOAF.Person

  property :first_name, predicate: RDF::FOAF.name
  property :description, predicate: RDF::DC.description
end

steve = Person.new
steve.first_name = 'Steve'
steve.description = 'Funny-looking'

steve.as_document
 => {"_id"=>BSON::ObjectId('542f0c124169720ea0000000'), "first_name"=>{"en"=>"Steve"}, "description"=>{"en"=>"Funny-looking"}}

steve.as_jsonld
 # => {
 #    "@context": {
 #        "dc": "http://purl.org/dc/terms/",
 #        "foaf": "http://xmlns.com/foaf/0.1/"
 #    },
 #    "@id": "http://example.org/people/542f0c124169720ea0000000",
 #    "@type": "foaf:Person",
 #    "dc:description": {
 #        "@language": "en",
 #        "@value": "Funny-looking"
 #   },
 #   "foaf:name": {
 #        "@language": "en",
 #        "@value": "Steve"
 #   }
 # }
```

The `#property` method takes care of setting both Mongoid fields and ActiveTriples properties.  Properties with literal values are localized by default.  Properties with a supplied `:class_name` will create a has-and-belongs-to-many (HABTM) relation:

```ruby
class Person
  include Ladder::Resource

  configure type: RDF::FOAF.Person

  property :first_name, predicate: RDF::FOAF.name
  property :books, predicate: RDF::FOAF.made, class_name: 'Book'
end

class Book
  include Ladder::Resource

  configure type: RDF::DC.BibliographicResource

  property :title, predicate: RDF::DC.title
  property :people, predicate: RDF::DC.creator, class_name: 'Person'
end

b = Book.new(title: 'Heart of Darkness')
=> #<Book _id: 542f28d44169721941000000, title: {"en"=>"Heart of Darkness"}, person_ids: nil>

b.people << Person.new(first_name: 'Joseph Conrad')
=> [#<Person _id: 542f28dd4169721941010000, first_name: {"en"=>"Joseph Conrad"}, book_ids: [BSON::ObjectId('542f28d44169721941000000')]>]

b.as_jsonld
 # => {
 #    "@context": {
 #        "dc": "http://purl.org/dc/terms/"
 #    },
 #    "@id": "http://example.org/books/542f28d44169721941000000",
 #    "@type": "dc:BibliographicResource",
 #    "dc:creator": {
 #        "@id": "http://example.org/people/542f28dd4169721941010000"
 #    },
 #    "dc:title": {
 #        "@language": "en",
 #        "@value": "Heart of Darkness"
 #    }
 # }
```

You'll notice that only the RDF node for the Book object on which `#as_jsonld` was called is serialized.  To include the entire graph for related objects, use the `related: true` option:

```ruby
b.as_jsonld related: true
 # => {
 #    "@context": {
 #        "dc": "http://purl.org/dc/terms/",
 #        "foaf": "http://xmlns.com/foaf/0.1/"
 #    },
 #    "@graph": [
 #        {
 #            "@id": "http://example.org/books/542f28d44169721941000000",
 #            "@type": "dc:BibliographicResource",
 #            "dc:creator": {
 #                "@id": "http://example.org/people/542f28dd4169721941010000"
 #            },
 #            "dc:title": {
 #                "@language": "en",
 #                "@value": "Heart of Darkness"
 #            }
 #        },
 #        {
 #            "@id": "http://example.org/people/542f28dd4169721941010000",
 #            "@type": "foaf:Person",
 #            "foaf:made": {
 #                "@id": "http://example.org/books/542f28d44169721941000000"
 #            },
 #            "foaf:name": {
 #                "@language": "en",
 #                "@value": "Joseph Conrad"
 #            }
 #        }
 #    ]
 # }
```

If you want more control over how relations are defined (eg. in the case of embedded or 1:n relations), you can just use regular Mongoid and ActiveTriples syntax:

```ruby
class Person
  include Ladder::Resource

  configure type: RDF::FOAF.Person

  property :first_name, predicate: RDF::FOAF.name

  embeds_one :address, class_name: 'Place'
  property :address, predicate: RDF::FOAF.based_near
end

class Place
  include Ladder::Resource

  configure type: RDF::VCARD.Address

  property :city, predicate: RDF::VCARD.locality
  property :country, predicate: RDF::VCARD.send('country-name')
  
  embedded_in :resident, class_name: 'Person', inverse_of: :address
  property :resident, predicate: RDF::VCARD.agent
end

steve = Person.new(first_name: 'Steve')
=> #<Person _id: 542f341e41697219a2000000, first_name: {"en"=>"Steve"}, address: nil>

steve.address = Place.new(city: 'Toronto', country: 'Canada')
=> #<Place _id: 542f342741697219a2010000, city: {"en"=>"Toronto"}, country: {"en"=>"Canada"}, resident: nil>

steve.as_jsonld
 # => {
 #    "@context": {
 #        "foaf": "http://xmlns.com/foaf/0.1/",
 #        "vcard": "http://www.w3.org/2006/vcard/ns#"
 #    },
 #    "@graph": [
 #        {
 #            "@id": "http://example.org/places/542f342741697219a2010000",
 #            "@type": "vcard:Address",
 #            "vcard:agent": {
 #                "@id": "http://example.org/people/542f341e41697219a2000000"
 #            },
 #            "vcard:country-name": {
 #                "@language": "en",
 #                "@value": "Canada"
 #            },
 #            "vcard:locality": {
 #                "@language": "en",
 #                "@value": "Toronto"
 #            }
 #        },
 #        {
 #            "@id": "http://example.org/people/542f341e41697219a2000000",
 #            "@type": "foaf:Person",
 #            "foaf:based_near": {
 #                "@id": "http://example.org/places/542f342741697219a2010000"
 #            },
 #            "foaf:name": {
 #                "@language": "en",
 #                "@value": "Steve"
 #            }
 #        }
 #    ]
 # }
```

Note in this case that both objects are included in the RDF graph, thanks to embedded relations. This can be useful to avoid additional queries to the database for objects that are tightly coupled.

#### Configuring Resources

If the LADDER_BASE_URI global constant is set, base URIs are dynamically generated based on the name of the model class.  However, you can still set the base URI for a class explicitly just as you would in ActiveTriples:

```ruby
LADDER_BASE_URI = 'http://example.org'

Person.resource_class.base_uri
=> #<RDF::URI:0x3fecf69da274 URI:http://example.org/people>

Person.configure base_uri: 'http://some.other.uri/'

Person.resource_class.base_uri
=> "http://some.other.uri/"
```

#### Dynamic Resources

In line with ActiveTriples' [Open Model](https://github.com/ActiveTriples/ActiveTriples#open-model) design, you can define properties on any Resource instance similarly to how you would on the class:

```ruby
class Person
  include Ladder::Resource::Dynamic

  configure type: RDF::FOAF.Person

  property :first_name, predicate: RDF::FOAF.name
end

steve = Person.new(first_name: 'Steve')

steve.description
=> NoMethodError: undefined method 'description' for #<Person:0x007fb54eb1d0b8>

steve.property :description, predicate: RDF::DC.description
steve.description = 'Funny-looking'

steve.as_document
=> {"_id"=>BSON::ObjectId('546669234169720397000000'),
 "first_name"=>{"en"=>"Steve"},
 "_context"=>{:description=>"http://purl.org/dc/terms/description"},
 "description"=>"Funny-looking"}

steve.as_jsonld
 # => {
 #    "@context": {
 #        "dc": "http://purl.org/dc/terms/",
 #        "foaf": "http://xmlns.com/foaf/0.1/"
 #    },
 #    "@id": "http://example.org/people/546669234169720397000000",
 #    "@type": "foaf:Person",
 #    "dc:description": "Funny-looking",
 #    "foaf:name": {
 #        "@language": "en",
 #        "@value": "Steve"
 #  }
```

Additionally, you can push RDF statements into a Resource instance like you would with ActiveTriples or RDF::Graph, noting that the subject is ignored since it is implicit:

```ruby
steve << RDF::Statement(nil, RDF::DC.description, 'Tall, dark, and handsome')
steve << RDF::Statement(nil, RDF::FOAF.depiction, RDF::URI('http://some.image/pic.jpg'))
steve << RDF::Statement(nil, RDF::FOAF.age, 32)

steve.as_document
=> {"_id"=>BSON::ObjectId('546669234169720397000000'),
 "first_name"=>{"en"=>"Steve"},
 "_context"=>
  {:description=>"http://purl.org/dc/terms/description",
   :depiction=>"http://xmlns.com/foaf/0.1/depiction",
   :age=>"http://xmlns.com/foaf/0.1/age"},
 "description"=>"Tall, dark, and handsome",
 "depiction"=>"http://some.image/pic.jpg",
 "age"=>32}

steve.as_jsonld
 # => {
 #    "@context": {
 #        "dc": "http://purl.org/dc/terms/",
 #        "foaf": "http://xmlns.com/foaf/0.1/",
 #        "xsd": "http://www.w3.org/2001/XMLSchema#"
 #    },
 #    "@id": "http://example.org/people/546669234169720397000000",
 #    "@type": "foaf:Person",
 #    "dc:description": "Tall, dark, and handsome",
 #    "foaf:age": {
 #        "@type": "xsd:integer",
 #        "@value": "32"
 #    },
 #    "foaf:depiction": {
 #        "@id": "http://some.image/pic.jpg"
 #    },
 #    "foaf:name": {
 #        "@language": "en",
 #        "@value": "Steve"
 #    }
 #	}
```

Note that due to the way Mongoid handles dynamic fields, dynamic properties **can not** be localized.  They can be any kind of literal, but they **can not** be a related object. They can, however, contain a reference to the related object's URI.

### Indexing for Search

You can also index your model classes for keyword searching through ElasticSearch by mixing in the Ladder::Searchable module:

```ruby
class Person
  include Ladder::Resource
  include Ladder::Searchable

  configure type: RDF::FOAF.Person

  property :first_name, predicate: RDF::FOAF.name
  property :description, predicate: RDF::DC.description
end

kimchy = Person.new
kimchy.first_name = 'Shay'
kimchy.description = 'Real genius'
```

In order to enable indexing, call the `#index_for_search` method on the class:

```ruby
Person.index_for_search
=> :as_indexed_json

kimchy.as_indexed_json
=> {"description"=>"Real genius", "first_name"=>"Shay"}

kimchy.save
=> true

results = Person.search 'shay'
 # => #<Elasticsearch::Model::Response::Response:0x007fa2ca82a9f0
 # @klass=[PROXY] Person,
 # @search=
 # #<Elasticsearch::Model::Searching::SearchRequest:0x007fa2ca830a58
 #  @definition={:index=>"people", :type=>"person", :q=>"Shay"},
 #  @klass=[PROXY] Person,
 #  @options={}>>
 
results.count
=> 1

results.first._source
=> {"description"=>"Real genius", "first_name"=>"Shay"}

results.records.first == kimchy
=> true
```

When indexing, you can control how your model is stored in the index by supplying the `as: :jsonld` or `as: :qname` options:

```ruby
Person.index_for_search as: :jsonld
=> :as_indexed_json

kimchy.as_indexed_json
 # => {
 #   "@context": {
 #       "dc": "http://purl.org/dc/terms/",
 #       "foaf": "http://xmlns.com/foaf/0.1/"
 #   },
 #   "@id": "http://example.org/people/543b457b41697231c5000000",
 #   "@type": "foaf:Person",
 #   "dc:description": {
 #       "@language": "en",
 #       "@value": "Real genius"
 #   },
 #   "foaf:name": {
 #       "@language": "en",
 #       "@value": "Shay"
 #   }
 # }

Person.index_for_search as: :qname
=> :as_indexed_json

kimchy.as_indexed_json
 # => {
 #   "dc": {
 #       "description": { "en": "Real genius" }
 #   },
 #   "foaf": {
 #       "name": { "en": "Shay" }
 #   },
 #   "rdf": {
 #       "type": "foaf:Person"
 #   }
 # }
```

You can also index related objects as framed JSON-LD or hierarchical qname, by again using the `related: true` option:

```ruby
class Project
  include Ladder::Resource
  include Ladder::Searchable

  configure type: RDF::DOAP.Project

  property :project_name, predicate: RDF::DOAP.name
  property :description, predicate: RDF::DC.description
  property :developers, predicate: RDF::DOAP.developer, class_name: 'Person'
end

Person.property :projects, predicate: RDF::FOAF.made, class_name: 'Project'

es = Project.new(project_name: 'ElasticSearch', description: 'You know, for search')
es.developers << kimchy
es.save

Person.index_for_search as: :jsonld, related: true
=> :as_indexed_json
Project.index_for_search as: :jsonld, related: true
=> :as_indexed_json

kimchy.as_indexed_json
 # => {
 #    "@context": {
 #        "dc": "http://purl.org/dc/terms/",
 #        "doap": "http://usefulinc.com/ns/doap#",
 #        "foaf": "http://xmlns.com/foaf/0.1/"
 #    },
 #    "@id": "http://example.org/people/543b457b41697231c5000000",
 #    "@type": "foaf:Person",
 #    "dc:description": {
 #        "@language": "en",
 #        "@value": "Real genius"
 #    },
 #    "foaf:made": {
 #        "@id": "http://example.org/projects/544562c24169728b4e010000",
 #        "@type": "doap:Project",
 #        "dc:description": {
 #            "@language": "en",
 #            "@value": "You know, for search"
 #        },
 #        "doap:developer": {
 #            "@id": "http://example.org/people/543b457b41697231c5000000"
 #        },
 #        "doap:name": {
 #            "@language": "en",
 #            "@value": "ElasticSearch"
 #        }
 #    },
 #    "foaf:name": {
 #        "@language": "en",
 #        "@value": "Shay"
 #    }
 # }

es.as_indexed_json
 # => {
 #    "@context": {
 #        "dc": "http://purl.org/dc/terms/",
 #        "doap": "http://usefulinc.com/ns/doap#",
 #        "foaf": "http://xmlns.com/foaf/0.1/"
 #    },
 #    "@id": "http://example.org/projects/544562c24169728b4e010000",
 #    "@type": "doap:Project",
 #    "dc:description": {
 #        "@language": "en",
 #        "@value": "You know, for search"
 #    },
 #    "doap:developer": {
 #        "@id": "http://example.org/people/543b457b41697231c5000000",
 #        "@type": "foaf:Person",
 #        "dc:description": {
 #            "@language": "en",
 #            "@value": "Real genius"
 #        },
 #        "foaf:made": {
 #            "@id": "http://example.org/projects/544562c24169728b4e010000"
 #        },
 #        "foaf:name": {
 #            "@language": "en",
 #            "@value": "Shay"
 #        }
 #    },
 #    "doap:name": {
 #        "@language": "en",
 #        "@value": "ElasticSearch"
 #    }
 # }

Person.index_for_search as: :qname, related: true
=> :as_indexed_json
Project.index_for_search as: :qname, related: true
=> :as_indexed_json

kimchy.as_indexed_json
 # => {
 #    "dc": {
 #        "description": { "en": "Real genius" }
 #    },
 #    "foaf": {
 #        "made": {
 #            "dc": {
 #                "description": { "en": "You know, for search" }
 #            },
 #            "doap": {
 #                "developer": [ "people:544562b14169728b4e000000" ],
 #                "name": { "en": "ElasticSearch" }
 #            },
 #            "rdf": {
 #                "type": "doap:Project"
 #            }
 #        },
 #        "name": { "en": "Shay" }
 #    },
 #    "rdf": {
 #        "type": "foaf:Person"
 #    }
 # }

es.as_indexed_json
 # => {
 #    "dc": {
 #        "description": { "en": "You know, for search" }
 #    },
 #    "doap": {
 #        "developer": {
 #            "dc": {
 #                "description": { "en": "Real genius" }
 #            },
 #            "foaf": {
 #                "made": [ "projects:544562c24169728b4e010000" ],
 #                "name": { "en": "Shay" }
 #            },
 #            "rdf": {
 #                "type": "foaf:Person"
 #            }
 #        },
 #        "name": { "en": "ElasticSearch" }
 #    },
 #    "rdf": {
 #        "type": "doap:Project"
 #    }
 # }
```

## Contributing

Anyone and everyone is welcome to contribute.  Go crazy.

1. Fork it ( https://github.com/mjsuhonos/ladder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Authors

MJ Suhonos / mj@suhonos.ca

## Acknowledgements

Many thanks to Christopher Knight [@NomadicKnight](https://twitter.com/Nomadic_Knight) for ceding the "ladder" gem name.  Check out his startup, [Adventure Local](http://advlo.com) / [@advlo_](https://twitter.com/Advlo_).

## License

Apache License Version 2.0
http://apache.org/licenses/LICENSE-2.0.txt
