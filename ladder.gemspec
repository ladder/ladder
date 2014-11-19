# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ladder/version'

Gem::Specification.new do |spec|
  spec.name          = "ladder"
  spec.version       = Ladder::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = "MJ Suhonos"
  spec.email         = "mj@suhonos.ca"
  spec.summary       = %q{Opinionated ActiveModel framework.}
  spec.description   = %q{Ladder is a metadata framework for RDF modelling, persistence, and full-text indexing.}
  spec.homepage      = "https://github.com/mjsuhonos/ladder"
  spec.license       = "APACHE2"
  spec.required_ruby_version     = '>= 1.9.3'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mongoid", "~> 4.0"
  spec.add_dependency "active-triples", "~> 0.3"
  spec.add_dependency "elasticsearch-model", "~> 0.1"
  
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "wirble", "~> 0.1"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency "simplecov", "~> 0.9"
end