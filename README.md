![Ladder logo](https://github.com/mjsuhonos/ladder/blob/master/logo.png)
# Ladder

Ladder is a highly scalable metadata framework written in Ruby using well-known components for Linked Data ([ActiveTriples](https://github.com/no-reply/ActiveTriples)/RDF.rb), persistence ([Mongoid](http://mongoid.org)/MongoDB), indexing ([ElasticSearch](http://www.elasticsearch.org)), asynchronicity ([Sidekiq](http://sidekiq.org)/Redis) and HTTP interaction ([Padrino](http://www.padrinorb.com)/Sinatra).  It is designed around the following philosophical goals:

- make it as modular (eg. the Ruby Way) as possible
- use as much commodity (ie. non-LAM-specific) tooling as possible
- make it as easy to use (ie. little programming required) as possible

## History

Ladder was loosely conceived over the course of several years prior to 2011.  In early 2012, Ladder began existence as an opportunity to escape from a decade of LAMP development and become familiar with Ruby.  From 2012 to late 2013, a closed prototype was built under the auspices of [Deliberate Data](http://deliberatedata.com) as a proof-of-concept to test the feasibility of the design.

From mid-2014, Ladder is being re-architected as a series of Ruby gems that can be used individually and incorporated within existing Ruby frameworks (eg. [Project Hydra](http://projecthydra.org)), or used together as a comprehensive stack.  Ladder is intended to encourage the LAM community to think less dogmatically about our established (often monolithic and/or niche) toolsets and instead embrace a broader vision of using non-LAM specific technologies.

### There's Nothing Here!

The original [prototype](https://github.com/mjsuhonos/ladder/tree/prototype) branch is available, as is an [experimental](https://github.com/mjsuhonos/ladder/tree/l2) branch.  Core modules will be committed shortly once the gem structure (likely under the name ActiveLadder) is completed and the first gem is refactored out.

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

TODO: Write usage instructions here

## Contributing

Anyone and everyone is welcome to contribute.  Go crazy.

1. Fork it ( https://github.com/[my-github-username]/ladder/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Authors

MJ Suhonos [@mjsuhonos](http://twitter.com/mjsuhonos) / [@cyxohoc](http://twitter.com/cyxohoc) / mj@suhonos.ca

## Acknowledgements

Many thanks to Christopher Knight [@NomadicKnight](https://twitter.com/Nomadic_Knight) for ceding the "ladder" gem name.  Check out his startup, [Adventure Local](http://advlo.com) / [@advlo_](https://twitter.com/Advlo_).

## License

Apache License Version 2.0
http://apache.org/licenses/LICENSE-2.0.txt