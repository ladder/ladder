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
        hash = Marshal.load(Marshal.dump(self.to_hash))

        if opts[:localize]
          hash.each do |name, vocab|
            next unless vocab.is_a? Hash

            vocab.each do |field, locales|
              if locales.is_a? Hash
                # we have a non-localized hash
                # FIXME: this looks like it only works for one locale; double-check
                locales.each do |locale, values|
                  hash[name][field] = values
                end
              end
            end
          end

          hash[:heading] = lookup(hash[:heading])
          hash[:heading_ancestors] = lookup(hash[:heading_ancestors])
        end

        self.class.normalize(hash, opts)
      end

      #
      # Copied from Mongoid::Fields::Localized
      #
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