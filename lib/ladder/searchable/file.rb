module Ladder::Searchable::File
  extend ActiveSupport::Concern

  included do
    # Index binary content using Elasticsearch mapper attachment plugin
    # https://github.com/elasticsearch/elasticsearch-mapper-attachments
    mapping do
      indexes :base64, type: 'attachment'#, path: 'full', fields: { base64: { store: false } }
    end

    # Explicitly set mapping definition on index
    self.__elasticsearch__.create_index!
  end

  ##
  # Return a Base64-encoded copy of data
  def as_indexed_json(opts = {})
    { base64: Base64.encode64(data) }
  end

end