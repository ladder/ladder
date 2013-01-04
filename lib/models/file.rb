module Model

  class File
    # contstants for file types
    MARC = 0
    MODS = 1
    DBPEDIA = 2

    include Mongoid::Document
    include Mongoid::Paranoia
    include Mongoid::Timestamps

    field :data, type: Model::CompressedBinary
    field :type, type: Integer # constant as above

    belongs_to :resource
  end

end