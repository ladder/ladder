module Tire

  module Results

    class Item

      attr_accessor :diff

      def class
        defined?(::Padrino) && @attributes[:_type] ? @attributes[:_type].camelize.constantize : super
      rescue NameError
        super
      end

      def to_normalized_hash(opts={})
        # NB: refactor/reconsider :localize option in ClassMethods#normalize
        hash = self.class.normalize(self.to_hash, opts.except(:localize))

        if opts[:localize]
          hash.each do |name, vocab|
            vocab.each do |field, locales|
              hash[name][field] = lookup(locales) unless locales.nil?
            end
          end
        end

        hash
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