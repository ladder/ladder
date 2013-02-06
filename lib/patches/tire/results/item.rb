module Tire

  module Results

    class Item

      attr_accessor :diff

      def class
        defined?(::Padrino) && @attributes[:_type] ? @attributes[:_type].camelize.constantize : super
      rescue NameError
        super
      end

      def normalize(opts={})
        hash = self.to_hash

        if opts[:localize]
          hash.select {|key| self.class.vocabs.keys.include? key}.each do |name, vocab|
            vocab.each do |field, values|
              hash[name][field] = lookup(values)
            end
          end
        end

        self.class.normalize(Hash[hash], opts)
      end

      def lookup(object)
        locale = ::I18n.locale
        if ::I18n.respond_to?(:fallbacks)
          object[::I18n.fallbacks[locale].find{ |loc| object[loc] }]
        else
          object[locale.to_s]
        end
      end

    end
  end

end