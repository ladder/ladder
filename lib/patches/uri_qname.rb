module RDF
  class URI

    def qname
      # store defined vocab URIs as a run-time constant
      @@vocab_uris ||= Vocabulary.map {|vocab| {vocab.equal?(RDF) ? :rdf : vocab.__prefix__ => vocab.to_uri.to_s}}.reduce Hash.new, :merge

      if self.to_s =~ %r([:/#]([^:/#]*)$)
        local_name = $1
        vocab_uri  = local_name.empty? ? self.to_s : self.to_s[0...-(local_name.length)]

        # this is much faster than the old method
        if prefix = @@vocab_uris.key(vocab_uri)
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