module Moped
  module BSON
    class Binary

      def initialize(type, data)
        @type = type
        @data = data.force_encoding('ASCII-8BIT')
      end

      def to_s
        # FIXME: must store original encoding somewhere
        data.force_encoding('UTF-8').to_s
      end

    end
  end
end