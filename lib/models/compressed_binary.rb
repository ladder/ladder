#
# Compress binary objects for storage
# @see: https://github.com/mongoid/mongoid/issues/2219#issuecomment-7161839
#
# Note: Snappy and LZ4 are both about 50% faster, but about 35% larger, than zlib
# Snappy, LZ4 -> 65%  ;  Zlib -> 48%
#
# @see: https://github.com/willglynn/snappy-ruby
# @see: https://github.com/komiya-atsushi/lz4-ruby
#

module Model

  class CompressedBinary

    attr_reader :object

    def initialize(object)
      @object = object
    end

    def mongoize
      return unless self
      compressed_string = LZ4::compress(Marshal.dump(object))

      # if the object is larger than a single GridFS chunk, use GridFS
      if compressed_string.size > Mongoid::GridFs::file_model.new.chunkSize
        file = Mongoid::GridFs.put(StringIO.new(compressed_string))
        file.id
      else
        serialized_object = Moped::BSON::Binary.new(:generic, compressed_string)
      end
    end

    def self.mongoize(object)
      if object.is_a?(CompressedBinary)
        object.mongoize
      else
        CompressedBinary.new(object).mongoize
      end
    end

    def self.demongoize(serialized_object)
      return unless serialized_object

      # if we have an ObjectId, retrieve the file from GridFS
      if serialized_object.is_a? Moped::BSON::ObjectId
        file = Mongoid::GridFs.get(serialized_object)
        decompressed_string = LZ4::uncompress(file.data.to_s)
      else
        # otherwise it's a Moped::BSON::Binary
        decompressed_string = LZ4::uncompress(serialized_object.to_s)
      end

      Marshal.load(decompressed_string)
    end

  end

end