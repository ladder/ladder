module Model

  class File
    include Mongoid::Document
    include Mongoid::Pagination
    include Mongoid::Paranoia
    include Mongoid::Timestamps

    extend Model::Core::FOCB

    field :data,          type: Model::CompressedBinary
    field :content_type,  type: String  # IANA MIME-type
    field :length,        type: Integer
    field :md5,           type: Moped::BSON::Binary

    index({ md5: 1 })

    set_callback :save, :before, :find_length
    set_callback :save, :before, :generate_md5

    belongs_to :resource
    belongs_to :concept
    belongs_to :agent

    def find_length
      self.length = self.data.size
    end

    def generate_md5
      self.md5 = Moped::BSON::Binary.new(:md5, Digest::MD5.digest(self.data))
    end

  end

end