class Compressor
  include Sidekiq::Worker

  def self.compression_types
    types = [:none, :gzip]
    types << :lz4 if Object.const_defined?('LZ4')
    types << :snappy if Object.const_defined?('Snappy')
    types
  end

  def perform(file_id, compression = :gzip)
    @file = Mongoid::GridFS.get(file_id)

    # don't re-process data with the same compression type
    compression = nil if :none == compression.to_sym
    return if compression == @file.compression

    # pass through attributes to re-create the file
    opts = @file.attributes.symbolize_keys.slice(:_id, :contentType, :uploadDate, :filename)

    # set the compresson type
    opts[:compression] = compression unless compression.nil?

    compressed = self.class.compress(@file.data, compression)

    # delete the existing file
    Mongoid::GridFS.delete(@file.id)

    # create a replacement file
    Mongoid::GridFS.put(StringIO.new(compressed), opts)
  end

  def self.compress(data, compression)
    case compression
       when :gzip
         Zlib::Deflate.deflate(data, Zlib::BEST_COMPRESSION)

       when :lz4
         raise ArgumentError, "Unavailable compression type : #{compression}" unless Object.const_defined?('LZ4')
         LZ4::compressHC(data)

       when :snappy
         raise ArgumentError, "Unavailable compression type : #{compression}" unless Object.const_defined?('Snappy')
         Snappy::compress(data)

      else
        data
    end
  end

  def self.decompress(data, compression)
    case compression
      when :gzip
        Zlib::Inflate.inflate(data)

      when :lz4
        raise ArgumentError, "Unavailable compression type : #{compression}" unless Object.const_defined?('LZ4')
        LZ4::uncompress(data)

      when :snappy
        raise ArgumentError, "Unavailable compression type : #{compression}" unless Object.const_defined?('Snappy')
        Snappy::uncompress(data)

      else
        data
    end
  end
end