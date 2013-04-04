module Model

  module Embedded

    def self.included(base)
      base.send :include, Mongoid::Document
#      base.send :include, Mongoid::Timestamps
      base.send :include, Mongoid::History::Trackable
      base.send :include, Easel::Bindable
    end

    def to_uri
      vocabularies.first.to_uri
    end

    def dynamic_attributes
      attributes.keys - fields.keys - _protected_attributes[:default].to_a
    end

    def static_attributes
      fields.keys - dynamic_attributes - _protected_attributes[:default].to_a
    end

  end

end