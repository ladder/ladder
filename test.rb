require_relative 'lib/ladder'
require 'mongoid'

Mongoid.load!('mongoid.yml', :development)
Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
Mongoid.purge!

LADDER_BASE_URI = 'http://example.org'

class Test
  include Ladder::File
end

t = Test.new data: 'this is a test'

binding.pry