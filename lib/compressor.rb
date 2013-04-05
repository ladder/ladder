class Compressor
  include Sidekiq::Worker

  def perform(file_id, compression = :gzip)
    @file = Mongoid::GridFS.get(file_id)

    # don't re-process compressed data
    return if compression == @file.compression

    # select compression type
    case compression
      when :gzip
        reader = StringIO.new(Zlib::Deflate.deflate(@file.data, Zlib::BEST_COMPRESSION))
=begin
        reader, writer = IO.pipe; reader.binmode; writer.binmode
        gz = Zlib::GzipWriter.new(writer, Zlib::BEST_COMPRESSION, Zlib::DEFAULT_STRATEGY)
        gz.write @file.data
        gz.close
=end

      when :lz4
        if Object.const_defined?('LZ4')
          reader = StringIO.new(LZ4::compressHC(@file.data))
        else
          raise ArgumentError, "Unavailable compression type : #{compression}"
        end

      when :snappy
        if Object.const_defined?('Snappy')
          reader = StringIO.new(Snappy::compress(@file.data))
        else
          raise ArgumentError, "Unavailable compression type : #{compression}"
        end

      else
        raise ArgumentError, "Unsupported compression type : #{compression}"
    end

    # pass through attributes to re-create the file
    opts = @file.attributes.symbolize_keys.slice(:_id, :contentType, :uploadDate, :filename)
    opts[:compression] = compression

    # delete the existing file
    Mongoid::GridFS.delete(@file.id)

    # create a replacement file
    Mongoid::GridFS.put(reader, opts)
  end

end