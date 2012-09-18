# compress/encode imported data to save space/memory in Mongo
class CompressedBinary
  include Mongoid::Fields::Serializable

  def serialize(string)
    # compress string for storage
    string ? Base64.encode64(ActiveSupport::Gzip.compress(string)) : string
  end

  def deserialize(compressed)
    # decompress string
    compressed ? ActiveSupport::Gzip.decompress(Base64.decode64(compressed)) : compressed
  end

end