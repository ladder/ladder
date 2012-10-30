#
# Static class for helper methods
# FIXME: refactor these into the appropriate classes if possible
#

class LadderHelper

  def self.dynamic_chunk(klass_or_collection, factor = 1)

    # super rough/hacky free mem calculation (includes inactive)
    mem_total_bytes = `sysctl -n hw.memsize`.to_i
    return 1000 if 0 == mem_total_bytes

    if klass_or_collection.is_a? Mongoid::Collection
      stats = klass_or_collection.stats
    else
      stats = klass_or_collection.collection.stats
    end

    mem_used_bytes = `ps -Ao rss=`
    mem_free_bytes = mem_total_bytes - mem_used_bytes.split.map(&:to_i).inject(&:+).to_i * 1024
    max_per_proc = (klass_or_collection.size(true).to_f / Parallel.processor_count.to_f)
    max_per_free = mem_free_bytes.to_f / (stats['avgObjSize'].to_f * Parallel.processor_count.to_f)

    # minimum chunk size is 1000
    chunk_size = [([max_per_proc.to_f, max_per_free.to_f].min + 1).ceil / factor, 1000].max

    chunk_size
  end

  def self.chunkify(klass_or_collection, opts = {})

    options = {:chunk_num => 1, :per_chunk => dynamic_chunk(klass_or_collection)}.merge(opts)

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