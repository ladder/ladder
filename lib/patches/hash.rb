class Hash

  def sort_by_key(recursive=false, &block)
    self.keys.sort(&block).reduce({}) do |seed, key|
      seed[key] = self[key]
      if recursive && seed[key].is_a?(Hash)
        seed[key] = seed[key].sort_by_key(true, &block)
      end
      seed
    end
  end

  # NB THIS IS DESTRUCTIVE
  # TODO: refactor to be non-modifying
  def normalize(opts={})
    self.symbolize_keys!

    # Strip specified fields
    # TODO: parameterize
    self.except! :_id, :rdf_types

    # Reject nil values
    self.reject! { |key, value| value.nil? }

    # Reject empty values
    self.reject! { |key, value| value.kind_of? Enumerable and value.empty? }

    # Recurse into Hash values
    self.values.select { |value| value.is_a? Hash }.each{ |h| h.normalize(opts) }

    self
  end

end