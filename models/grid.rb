class Grid
#  include Mongoid::Document
#  include Mongoid::Pagination

  class << self
    def where(conditions = {})
      Mongoid::GridFS.file_model.where(conditions)
    end

    def find(id)
      Mongoid::GridFS.find(:id => id)
    end

    def delete(id)
      Mongoid::GridFS.delete(id)
    end
  end

  attr_accessor :data, :content_type

#  field :content_type,  type: String

  def initialize(*args)
    @data = args.first[:data] if args.first[:data]
#    super
  end

  def save
    Mongoid::GridFS.put(StringIO.new(data), attributes.except(:data))
  rescue
    true
  end

=begin

  def id
    @file.id
  end

  def length
    @file.length
  end

  def md5
    @file.md5
  end

  def generate_md5
    # NOT IMPLEMENTED
  end

  def data
    @file.data
  end

  def data=(object)
    @file.data = object
  end

  def content_type
    @file.content_type
  end

  def content_type=(string)
    @file.content_type = string
  end
=end
=begin
  class << self; attr_accessor :grid end

  self.grid = ::Mongoid::GridFS

  def grid
    self.class.grid
  end
=end
end