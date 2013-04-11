class Tenant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :api_key
  field :database

  before_validation :generate_api_key

  validates_presence_of :api_key
  validates_presence_of :database

  store_in database: 'ladder', collection: 'tenants'

  def generate_api_key
    key = SecureRandom.hex
    self.api_key = key unless self.api_key
    key
  end

  def to_hash
    self.serializable_hash
  end

end