require 'mongoid'
require 'mongoid/config/validators/option'
require 'uri'

module Ladder
  module Config
    extend self
    extend ::Mongoid::Config::Options

    LOCK = Mutex.new

    option :base_uri,            default: URI('urn:x-ladder') # typically a URL (configured)
    option :localize_fields,     default: false               # self-explanatory
    option :one_sided_relations, default: false               # otherwise HABTM

    # Get all the models in the application - this is everything that includes
    # Mongoid::Document.
    #
    # @example Get all the models.
    #   config.models
    #
    # @return [ Array<Class> ] All the models in the application.
    #
    # @since 3.1.0
    def models
      @models ||= []
    end

    # Register a model in the application with Mongoid.
    #
    # @example Register a model.
    #   config.register_model(Band)
    #
    # @param [ Class ] klass The model to register.
    #
    # @since 3.1.0
    def register_model(klass)
      LOCK.synchronize do
        models.push(klass) unless models.include?(klass)
      end
    end

    # From a hash of settings, load all the configuration.
    #
    # @example Load the configuration.
    #   config.load_configuration(settings)
    #
    # @param [ Hash ] settings The configuration settings.
    #
    # @since 3.1.0
    def load_configuration(settings)
      configuration = settings.with_indifferent_access
      self.options = configuration[:options]
    end

    # Set the configuration options. Will validate each one individually.
    #
    # @example Set the options.
    #   config.options = { raise_not_found_error: true }
    #
    # @param [ Hash ] options The configuration options.
    #
    # @since 3.0.0
    def options=(options)
      if options
        options.each_pair do |option, value|
          ::Mongoid::Config::Validators::Option.validate(option)
          send("#{option}=", value)
        end
      end
    end
  end
end