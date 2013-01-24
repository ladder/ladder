module Model

  class File
    include Mongoid::Document
    include Mongoid::Paranoia
    include Mongoid::Timestamps

    field :data,          type: Model::CompressedBinary
    field :content_type,  type: String  # IANA MIME-type

    belongs_to :resource
    belongs_to :concept
    belongs_to :agent
  end

end