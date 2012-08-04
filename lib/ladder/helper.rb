class LadderHelper

  def self.dynamic_chunk(klass_or_collection, factor = 1)

    # super rough/hacky free mem calculation (includes inactive)
    mem_used_bytes = `ps -Ao rss=`.split.map(&:to_i).inject(&:+).to_i * 1024
    mem_total_bytes = `sysctl -n hw.memsize`.to_i
    mem_free_bytes = mem_total_bytes - mem_used_bytes

    if klass_or_collection.is_a? Mongoid::Collection
      stats = klass_or_collection.stats
    else
      stats = klass_or_collection.collection.stats
    end

    max_per_proc = (klass_or_collection.size(true).to_f / Parallel.processor_count.to_f)
    max_per_free = mem_free_bytes.to_f / (stats['avgObjSize'].to_f * Parallel.processor_count.to_f)

    # minimum chunk size is 10000; less causes problems
    chunk_size = [([max_per_proc.to_f, max_per_free.to_f].min + 1).ceil, 10000].max / factor
    num_chunks = (klass_or_collection.size(true).to_f / chunk_size.to_f).ceil

    puts "Using #{num_chunks} chunks of #{chunk_size} objects..."

    chunk_size
  end
end