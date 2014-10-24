require 'bson'
require 'mongoid/grid_fs'
require 'active_triples'

module Ladder::File
  extend ActiveSupport::Concern

  include ActiveTriples::Identifiable

  included do
    configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
  end

  attr_accessor :id

  ##
  # Make constructor as ActiveModel-like as possible
  #
  # eg. Ladder::File.new(StringIO.new, id: 'some_id')
  #     Ladder::File.new(data: '... binary data ...')
  #
  def initialize(*args)
    @readable = args.shift unless args.first.is_a? Hash

    args << {} unless args.last.is_a?(Hash)
    attrs = args.last.symbolize_keys

    self.id = attrs[:id] || attrs[:_id] || BSON::ObjectId.new
    @readable = attrs[:readable] || StringIO.new(attrs[:data].to_s)
    @file = attrs[:file]
  end

  def save
    @file = self.class.grid.put(@readable, {id: self.id})
  end

  module ClassMethods

    def grid
     @grid ||= Mongoid::GridFs.build_namespace_for name
    end
    
    def find(*args)
      id = args.shift unless args.first.is_a? Hash

      file = id ? grid.get(id) : grid.find(*args)

      self.new({id: id, file: file})
    end

  end

end