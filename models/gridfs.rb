class Mongoid::GridFS::Fs::File
  include Mongoid::Pagination

  field :compression, :type => String

  index :md5 => 1

  belongs_to :agent, index: true
  belongs_to :concept, index: true
  belongs_to :resource, index: true

  def data
    data = ''
    each{|chunk| data << chunk}
    Compressor.decompress(data, compression)
  end

  def model
    return {:resource => self.resource_id} if self.resource_id
    return {:agent => self.agent_id} if self.agent_id
    return {:concept => self.concept_id} if self.concept_id
  end

end