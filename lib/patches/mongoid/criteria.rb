#
# Extend Mongoid::Criteria class to add a #chunkify method for batch processing
#

module Mongoid

  class Criteria

    def chunkify(opts = {})

      # maximum chunks of 1000 to avoid mongo cursor timeouts for large sets
      per = [(self.size / Parallel.processor_count) + Parallel.processor_count, 1000].min
      options = {:per => per}.merge(opts)

      chunks = []

      0.step(self.size, options[:per]) do |offset|
        chunks << self.limit(options[:per]).skip(offset)
      end

      puts "Using #{chunks.size} chunks of #{options[:per]} objects..."

      # queries are executed in sequence, so traverse last-to-first
      chunks.reverse
    end

  end

end