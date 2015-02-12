module Ladder
  module Searchable
    module Resource
      extend ActiveSupport::Concern

      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
      def as_indexed_json(*)
        respond_to?(:serialized_json) ? serialized_json : as_json(except: [:id, :_id])
      end

      module ClassMethods
        ##
        # Specify type of serialization to use for indexing
        #
        # TODO: documentation
        # @param [Type] name1 more information
        # @param [Type] name2 more information
        # @return [Type, nil] describe return value(s)
        def index_for_search(*, &block)
          define_method(:serialized_json, block)
        end
      end
    end
  end
end
