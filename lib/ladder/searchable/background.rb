require 'active_job'

module Ladder::Searchable::Background
  extend ActiveSupport::Concern

  included do
    include Ladder::Searchable
    include GlobalID::Identification

    GlobalID.app = 'Ladder'

    after_create  { enqueue :index }
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

    def perform(operation, model)
      case operation
        when 'index'
          model.__elasticsearch__.index_document
        when 'update'
          model.__elasticsearch__.update_document
        when 'delete'
          model.__elasticsearch__.delete_document
        else raise ArgumentError, "Unknown operation '#{operation}'"
      end
    end

  end

end