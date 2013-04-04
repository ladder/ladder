class Mongoid::GridFS::Fs::File
  include Mongoid::Pagination
  include Mongoid::Paranoia

  field :compression

  belongs_to :agent, index: true
  belongs_to :concept, index: true
  belongs_to :resource, index: true
end