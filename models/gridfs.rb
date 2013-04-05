class Mongoid::GridFS::Fs::File
  include Mongoid::Pagination

  field :compression

  belongs_to :agent, index: true
  belongs_to :concept, index: true
  belongs_to :resource, index: true

  def data
    data = ''
    each{|chunk| data << chunk}

    case compression
      when :gzip
        Zlib::Inflate.inflate(data)
#        Zlib::GzipReader.new(StringIO.new(data)).read

      when :lz4
        if Object.const_defined?('LZ4')
          LZ4::uncompress(data)
        else
          raise ArgumentError, "Unable to decompress : #{compression}"
        end

      when :snappy
        if Object.const_defined?('Snappy')
          Snappy::uncompress(data)
        else
          raise ArgumentError, "Unable to decompress : #{compression}"
        end

      else
        data
    end
  end

end