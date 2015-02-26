module Ladder
  module Searchable
    module File
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
      # Serialize a Base64-encoded version of data for indexing
      #
      # @see Elasticsearch::Model::Serializing#as_indexed_json
      #
      # @param optional [Hash] options (unused)
      # @return [Hash] a serialized version of the file
      def as_indexed_json(*)
        { file: Base64.encode64(data) }
      end
    end
  end
end
