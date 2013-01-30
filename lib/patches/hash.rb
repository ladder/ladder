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

  def normalize(opts={})
    self.symbolize_keys!

    # Strip id field
    self.except! :_id, :rdf_types
=begin
    # Modify Object ID references if specified
    if opts[:ids]

      self.each do |key, values|
        values.to_a.each do |value|

          # NB: have to use regexp matching for Tire Items
          if value.is_a? BSON::ObjectId or value.to_s.match(/^[0-9a-f]{24}$/)

            case opts[:ids]
              when :omit then
                #hash[key].delete value     # doesn't work as expected?
                self[key][values.index(value)] = nil

              when :resolve then
                model = :resource if opts[:resource_ids].include? value rescue nil
                model = :agent if opts[:agent_ids].include? value rescue nil
                model = :concept if opts[:concept_ids].include? value rescue nil
                model = opts[:type].to_sym if model.nil?

                self[key][values.index(value)] = {model => value.to_s}
            end
          end
        end

        # remove keys that are now empty
        self[key].to_a.compact!
      end

    end
=end
    # Reject nil values
    self.reject! { |key, value| value.nil? }

    # Reject empty values
    self.reject! { |key, value| value.kind_of? Enumerable and value.empty? }

    # Recurse into Hash values
    self.values.select { |value| value.is_a? Hash }.each{ |h| h.normalize(opts) }

    self
  end

end