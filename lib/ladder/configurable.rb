module Ladder
  module Configurable
    extend ActiveSupport::Concern

    module ClassMethods
      ##
      # Set a default base URI based on the Ladder::Config settings
      #
      # @return [RDF::URI]
      def base_uri
        RDF::URI.new(Ladder::Config.settings[:base_uri]) / name.underscore.pluralize
      end

      protected

      ##
      # Register with Ladder and set the default base URI
      #
      # @return [void]
      def configure_model
        configure base_uri: base_uri
        Ladder::Config.register_model self unless Ladder::Config.models.include? self
      end
    end
  end
end
