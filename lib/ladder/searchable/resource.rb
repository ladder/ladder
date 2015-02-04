module Ladder
  module Searchable
    module Resource
      extend ActiveSupport::Concern

      def as_indexed_json(*)
        respond_to?(:serialized_json) ? serialized_json : as_json(except: [:id, :_id])
      end

      module ClassMethods
        ##
        # Specify type of serialization to use for indexing
        #
        def index_for_search(*, &block)
          define_method(:serialized_json, block)
        end
      end
    end
  end
end
