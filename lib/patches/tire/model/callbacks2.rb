module Tire

  module Model

    module Callbacks2

      extend ActiveSupport::Concern

      included do

        # Update index on model instance change or destroy.
        #
        set_callback :save, :after, :update_index_if_changed
        set_callback :destroy, :after, :update_index

        # Add neccessary infrastructure for the model, when missing in
        # some half-baked ActiveModel implementations.
        #
        if respond_to?(:before_destroy) && !instance_methods.map(&:to_sym).include?(:destroyed?)
          class_eval do
            before_destroy  { @destroyed = true }
            def destroyed?; !!@destroyed; end
          end
        end

        class_eval "def base_class; ::#{self.name}; end"
      end

      private

      def update_index_if_changed
        tire.update_index if self.changed?
      end

    end

  end

end