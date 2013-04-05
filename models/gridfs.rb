class Mongoid::GridFS::Fs::File
  include Mongoid::Pagination

  field :compression

  belongs_to :agent, index: true
  belongs_to :concept, index: true
  belongs_to :resource, index: true

  def data
    data = ''
    each{|chunk| data << chunk}
    Compressor.decompress(data, compression)
  end

end