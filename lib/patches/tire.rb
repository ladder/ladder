module Tire
  class Index

    def get_id_from_document(document)
      old_verbose, $VERBOSE = $VERBOSE, nil # Silence Object#id deprecation warnings
      id = case
             when document.is_a?(Hash)
               document[:_id] || document['_id'] || document[:id] || document['id']
             when document.respond_to?(:id) && document.id != document.object_id
               document.id
           end
      $VERBOSE = old_verbose
      id.to_s
    end

  end
end

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

module Tire
  module Search

    class Query
      def ids(values, type=nil)
        if type
          @value = { :ids => { :values => values, :type => type }  }
        else
          @value = { :ids => { :values => values }  }
        end
      end
    end

  end
end

module Tire
  module Model

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