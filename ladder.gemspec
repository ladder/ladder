# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ladder/version'

Gem::Specification.new do |spec|
  spec.name          = 'ladder'
  spec.version       = Ladder::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = 'MJ Suhonos'
  spec.email         = 'mj@suhonos.ca'
  spec.summary       = 'ActiveModel Linked Data framework.'
  spec.description   = 'Dynamic framework for Linked Data modelling, persistence, and full-text indexing.'
  spec.homepage      = 'https://github.com/ladder/ladder'
  spec.license       = 'APACHE2'
  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split('\x0')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'active-triples', '~> 0.6'
  spec.add_dependency 'activejob', '~> 4.2'
  spec.add_dependency 'elasticsearch-model', '~> 0.1'
  spec.add_dependency 'mongoid', '~> 4.0'
  spec.add_dependency 'mongoid-grid_fs', '~> 2.1'

  spec.add_development_dependency 'awesome_print', '~> 1.6'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'mimemagic', '~> 0.2'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rubocop', '~> 0.28'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'wirble', '~> 0.1'
  spec.add_development_dependency 'yard', '~> 0.8'
end