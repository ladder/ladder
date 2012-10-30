#
# Static class for helper methods
# FIXME: refactor these into the appropriate classes if possible
#

class LadderHelper

  def self.chunkify(klass_or_collection, opts = {})

    # ensure we are dealing with a Mongoid::Criteria
    unless klass_or_collection.is_a? Mongoid::Criteria
      klass_or_collection = Mongoid::Criteria.new(klass_or_collection)
    end

    # default to chunks of 1000 to avoid mongo cursor timeouts for large sets
    options = {:chunk_num => 1, :per_chunk => 1000}.merge(opts)

    chunks = []
    while chunk = klass_or_collection.page(options[:chunk_num]).per(options[:per_chunk]) \
                            and chunk.size(true) > 0
      chunks << chunk
      options[:chunk_num] += 1
    end

    puts "Using #{chunks.size} chunks of #{options[:per_chunk]} objects..."

    # queries are executed in sequence, so traverse last-to-first
    chunks.reverse
  end

end