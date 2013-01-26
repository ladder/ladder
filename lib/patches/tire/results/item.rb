module Tire

  module Results

    class Item

      attr_reader :attributes

      def class
        defined?(::Padrino) && @attributes[:_type] ? @attributes[:_type].camelize.constantize : super
      rescue NameError
        super
      end

    end
  end

end