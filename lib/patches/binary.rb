module Moped
  module BSON
    class Binary

      def initialize(type, data)
        @type = type
        @data = data.force_encoding('ASCII-8BIT')
      end

    end
  end
end