module Ladder::Searchable::File
  extend ActiveSupport::Concern

  included do
    # Index binary content using Elasticsearch mapper attachment plugin
    # https://github.com/elasticsearch/elasticsearch-mapper-attachments
    mapping _source: { enabled: false } do
      indexes :file, type: 'attachment', fields: {
        file: { store: true },
        title: { store: true },
        date: { store: true },
        author: { store: true },
        keywords: { store: true },
        content_type: { store: true },
        content_length: { store: true },
        language: { store: true }
      }
    end

    # Explicitly set mapping definition on index
    __elasticsearch__.create_index!
  end

  ##
  # Return a Base64-encoded copy of data
  def as_indexed_json(opts = {})
    { file: Base64.encode64(data) }
  end
end
