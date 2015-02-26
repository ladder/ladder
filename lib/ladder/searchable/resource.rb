module Ladder
  module Searchable
    module Resource
      extend ActiveSupport::Concern

      ##
      # Serialize the resource as JSON for indexing
      #
      # @see Elasticsearch::Model::Serializing#as_indexed_json
      #
      # @return [Hash] a serialized version of the resource
      def as_indexed_json(*)
        respond_to?(:serialized_json) ? serialized_json : as_json(except: [:id, :_id])
      end

      module ClassMethods
        ##
        # Specify type of serialization to use for indexing;
        # if a block is provided, it is expected to return a Hash
        # that will be used in lieu of {#as_indexed_json} for
        # serializing the resource in the index
        #
        # @return [void]
        def index_for_search(&block)
          define_method(:serialized_json, block) if block_given?
        end
      end
    end
  end
end
