require 'active_job'
require 'sidekiq'

module Ladder::Searchable::Background
  extend ActiveSupport::Concern

  included do
    include Ladder::Searchable
    include GlobalID::Identification

    GlobalID.app = 'Ladder'

    after_save    { enqueue :index }
    after_update  { enqueue :update }
    after_destroy { enqueue :delete }
  end
  
  private
  
    def enqueue(operation)
      Indexer.queue_as self.class.name.underscore.pluralize
      Indexer.perform_later(operation.to_s, self)
    end

  class Indexer < ActiveJob::Base
    queue_as :elasticsearch

    Logger = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil
    Client = Elasticsearch::Client.new host: 'localhost:9200', logger: Logger

    def perform(operation, resource)
      case operation
        when 'index'
          resource.__elasticsearch__.index_document
        when 'update'
          resource.__elasticsearch__.update_document
        when 'delete'
          resource.__elasticsearch__.delete_document
        else raise ArgumentError, "Unknown operation '#{operation}'"
      end
    end

  end

end