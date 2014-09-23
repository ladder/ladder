# Ladder

![Ladder logo](https://github.com/mjsuhonos/ladder/blob/master/logo.png)

Ladder is a highly scalable Linked Data framework written in Ruby using well-known components for modelling (ActiveModel), persistence ([Mongoid](http://mongoid.org)/MongoDB), indexing ([ElasticSearch](http://www.elasticsearch.org)), asynchronicity ([Sidekiq](http://sidekiq.org)/Redis) and HTTP interaction ([Padrino](http://www.padrinorb.com)/Sinatra).  It is designed around the following philosophical goals:

- make it as modular (eg. the Ruby Way) as possible
- use as much commodity (ie. non-LAM-specific) tooling as possible
- make it as easy to use (ie. little programming required) as possible

## History

Ladder was loosely conceived over the course of several years prior to 2011.  In early 2012, Ladder began existence as an opportunity to escape from a decade of LAMP development and become familiar with Ruby.  From 2012 to late 2013, a closed prototype was built under the auspices of [Deliberate Data](http://deliberatedata.com) as a proof-of-concept to test the feasibility of the design.

From mid-2014, Ladder is being re-architected as a series of Ruby gems that can be used individually and incorporated within existing Ruby frameworks (eg. [Project Hydra](http://projecthydra.org)), or used together as a comprehensive stack.  Ladder is intended to encourage the LAM community to think less dogmatically about our established (often monolithic and/or niche) toolsets and instead embrace a broader vision of using non-LAM specific technologies.

### There's Nothing Here!

The original [prototype](https://github.com/mjsuhonos/ladder/blob/master/tree/prototype) branch is available, as is an [experimental](https://github.com/mjsuhonos/ladder/blob/master/tree/l2) branch.  Core modules will be committed shortly once the gem structure (likely under the name ActiveLadder) is completed and the first gem is refactored out.

## Contributors

Anyone and everyone is welcome to contribute.  Go crazy.

### Authors

MJ Suhonos [@mjsuhonos](http://twitter.com/mjsuhonos) / [@cyxohoc](http://twitter.com/cyxohoc) / mj@suhonos.ca

## License

Apache License Version 2.0
http://apache.org/licenses/LICENSE-2.0.txt