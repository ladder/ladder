module RDF
  class URI
    # Converts an object of this instance into a database friendly value.
    def mongoize
      to_s
    end

    # Get the object as it was stored in the database, and instantiate
    # this custom class from it.
    def self.demongoize(string)
      new(string)
    end
  end
end
