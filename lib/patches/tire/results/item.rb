module Tire

  module Results

    class Item

      attr_reader :attributes

      def class
        defined?(::Padrino) && @attributes[:_type] ? @attributes[:_type].camelize.constantize : super
      rescue NameError
        super
      end

      def normalize(opts={})
        # TODO: implement :localize option
        self.class.normalize(self.to_hash, opts)
      end

    end
  end

end