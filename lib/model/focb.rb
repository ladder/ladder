module Model

  module Core

    module FOCB

      # Override Mongoid #find_or_create_by
      # @see: http://rdoc.info/github/mongoid/mongoid/Mongoid/Finders
      def find_or_create_by(attrs = {})

        # use md5 fingerprint to query if a document already exists
        obj = self.new(attrs)
        query = self.where(:md5 => obj.generate_md5).hint(:md5 => 1)

        result = query.first
        return result unless result.nil?

        # otherwise create and return a new object
        obj.save
        obj
      end

    end

  end

end