module Tire
  module Model

    module Callbacks2

      # A hook triggered by the `include Tire::Model::Callbacks` statement in the model.
      #
      def self.included(base)

        # Update index on model instance change or destroy.
        #
        if base.respond_to?(:after_save) && base.respond_to?(:after_destroy)
          base.send :after_save,    :update_index
          base.send :after_destroy, :update_index
        end

        # Add neccessary infrastructure for the model, when missing in
        # some half-baked ActiveModel implementations.
        #
        if base.respond_to?(:before_destroy) && !base.instance_methods.map(&:to_sym).include?(:destroyed?)
          base.class_eval do
            before_destroy  { @destroyed = true }
            def destroyed?; !!@destroyed; end
          end
        end

      end

    end

  end
end
