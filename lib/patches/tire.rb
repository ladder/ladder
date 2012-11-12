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

#
# NB: THESE SHOULD APPEAR IN THE NEXT RUBYGEMS RELEASE OF TIRE
#
module Tire
  module Search

    class Search

      def min_score(value)
        @min_score = value
        self
      end

      def to_hash
        @options.delete(:payload) || begin
          request = {}
          request.update( { :indices_boost => @indices_boost } ) if @indices_boost
          request.update( { :query  => @query.to_hash } )    if @query
          request.update( { :sort   => @sort.to_ary   } )    if @sort
          request.update( { :facets => @facets.to_hash } )   if @facets
          request.update( { :filter => @filters.first.to_hash } ) if @filters && @filters.size == 1
          request.update( { :filter => { :and => @filters.map {|filter| filter.to_hash} } } ) if  @filters && @filters.size > 1
          request.update( { :highlight => @highlight.to_hash } ) if @highlight
          request.update( { :size => @size } )               if @size
          request.update( { :from => @from } )               if @from
          request.update( { :fields => @fields } )           if @fields
          request.update( { :script_fields => @script_fields } ) if @script_fields
          request.update( { :version => @version } )         if @version
          request.update( { :explain => @explain } )         if @explain
          request.update( { :min_score => @min_score } )     if @min_score
          request
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