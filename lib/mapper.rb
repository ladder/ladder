module Mapper

  class Mapper
    include ActiveSupport::DescendantsTracker
    include Sidekiq::Worker

    # Return an instance of an appropriate mapper for the given content type
    def self.create(content_type)
      descendants.each do |klass|
        return klass if klass.content_types.include? content_type
      end

      nil
    end

    def self.content_types
      descendants.map {|klass| klass.content_types}.flatten
    end

    def content_types
      self.class.content_types
    end

  end

end