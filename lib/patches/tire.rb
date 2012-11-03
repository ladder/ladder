module Tire
  module Results

    class Item

      def class
        defined?(::Padrino) && @attributes[:_type] ? @attributes[:_type].camelize.constantize : super
      rescue NameError
        super
      end

    end

  end

end

module Tire
  module Model

    # Main module containing the infrastructure for automatic updating
    # of the _ElasticSearch_ index on model instance create, update or delete.
    #
    # Include it in your model: `include Tire::Model::Callbacks`
    #
    # The model must respond to `after_save` and `after_destroy` callbacks
    # (ActiveModel and ActiveRecord models do so, by default).
    #
    module Callbacks2
      extend ActiveSupport::Concern

      included do

        # Update index on model instance change or destroy.
        #
        set_callback :save, :after, :update_index
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

      def update_index
        tire.update_index
      end

    end

  end
end