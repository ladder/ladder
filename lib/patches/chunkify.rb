#
# Extend Mongoid::Criteria class to add a #chunkify method for batch processing
#

module Mongoid
  class Criteria

    def chunkify(opts = {})
      # default to chunks of 1000 to avoid mongo cursor timeouts for large sets
      options = {:per => 1000}.merge(opts)

      chunks = []
      pages = (self.count / options[:per].to_f).ceil

      for i in 1..pages
        chunks << self.page(i).per(options[:per])
      end

      puts "Using #{chunks.size} chunks of #{options[:per]} objects..."

      # queries are executed in sequence, so traverse last-to-first
      chunks.reverse
    end

  end
end