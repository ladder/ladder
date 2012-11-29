module Model

  module Embedded

    def self.included(base)
      base.send :include, Mongoid::Document
      base.send :include, Easel::Bindable
    end

    def to_uri
      vocabularies.first.to_uri
    end

  end

end