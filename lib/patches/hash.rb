class Hash

  def deep_sort
    self.values.select { |value| value.is_a? Hash }.each{ |h| h.deep_sort }

    self.class[self.sort]
  end

  # NB: this is destructive
  def normalize!(opts={})
    # set default keys to strip
    except = opts[:except] || [:_id]

    self.symbolize_keys!

    # Strip specified keys
    self.except! *except

    # Reject nil values
    self.delete_if { |key, value| value.nil? }

    # Recurse into Hash values
    self.values.select { |value| value.is_a? Hash }.each{ |h| h.normalize!(opts) }

    # Reject empty values
    self.delete_if { |key, value| value.kind_of? Enumerable and value.empty? }

    # Sort keys recursively
    self.deep_sort
  end

end