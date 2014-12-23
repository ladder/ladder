require 'bson'
require 'mongoid/grid_fs'
require 'active_triples'
require 'open-uri'

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
    opts = args.last.is_a?(Hash) ? args.pop : {}

    self.id = opts[:id] || opts[:_id] || BSON::ObjectId.new

    @readable ||= StringIO.new(opts[:data].to_s)
    @file = @readable if @readable.respond_to? :data
  end
  
  ##
  # Make save behave like Mongoid::Document as much as possible
  def save
    # TODO: this is gross, refactor #readable
    return false if @file.nil? and readable.read.empty?
    @file ? @file.save : !! @file = self.class.grid.put(readable, {id: self.id})
  end

  ##
  # Output content of object from stored file or readable input
  def data(*opts)
    @file ? @file.data(*opts) : readable.read
  end
  
  ##
  # Allow setting data on existing object
  def data=(string)
    @readable = StringIO.new(string)
  end

  ##
  # Id-based object comparison
  def ==(o)
    self.id == o.id
  end

  alias_method :eql?, :==

  private
  
    def readable
      @readable.rewind if @readable.respond_to?(:rewind)
      @readable
    end

  module ClassMethods

    ##
    # Create a namespaced GridFS module for this class
    def grid
     @grid ||= Mongoid::GridFs.build_namespace_for name
    end
    
    ##
    # Behave like Mongoid::Document as much as possible
    def find(*args)
      id = args.shift unless args.first.is_a? Hash
      file = id ? grid.find(id: id) : grid.find(*args)

      self.new(file, {id: id})
    end

  end

end