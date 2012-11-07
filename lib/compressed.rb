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

class CompressedBinary

  attr_reader :object

  def initialize(object)
    @object = object
  end

  def mongoize
    return unless self
    compressed_string = LZ4::compress(@object.force_encoding('ASCII-8BIT'))
    serialized_object = Moped::BSON::Binary.new(:generic, compressed_string)
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
    decompressed_string = LZ4::uncompress(serialized_object.to_s)
    decompressed_string.to_s
  end
end