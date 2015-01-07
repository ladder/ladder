module Ladder::Searchable::File
  extend ActiveSupport::Concern

  ##
  # Generate a qname-based JSON representation
  #
  def as_qname(opts = {})
  end

  module ClassMethods
    ##
    # Specify type of serialization to use for indexing
    #
    def index_for_search(opts = {})
    end
  end
end