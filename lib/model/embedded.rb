module Model

  module Embedded

    def self.included(base)
      base.class_eval do
        include Mongoid::Document
        include Mongoid::History::Trackable
        include Easel::Bindable
      end
    end

    def to_uri
      vocabularies.first.to_uri
    end

  end

end