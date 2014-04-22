require 'rdf'

module RDF

  class URI

    # Take a qname array pair and return a URI
    def self.from_qname(qname)
      return nil if qname.nil?

      qname = [qname, nil] unless qname.is_a? Array and qname.size == 2
      prefix = Vocabulary.uri_from_prefix(qname.flatten.first)

      return nil if prefix.nil?

      if qname.last.nil?
        return self.intern(prefix)
      else
        return self.intern(self.new(prefix) / qname.last)
      end
    end

    def qname
      if self.to_s =~ %r([:/#]([^:/#]*)$)
        local_name = $1
        vocab_uri  = local_name.empty? ? self.to_s : self.to_s[0...-(local_name.length)]

        # this is much faster than the old method
        if prefix = Vocabulary.prefix_from_uri(vocab_uri)
          return [prefix, local_name.empty? ? nil : local_name.to_sym]
        end
      else
        Vocabulary.each do |vocab|
          vocab_uri = vocab.to_uri
          if self.start_with?(vocab_uri)
            prefix = vocab.equal?(RDF) ? :rdf : vocab.__prefix__
            local_name = self.to_s[vocab_uri.length..-1]
            return [prefix, local_name.empty? ? nil : local_name.to_sym]
          end
        end
      end
      return nil # no QName found
    end

  end

end