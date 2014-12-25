require 'bson'
require 'mongoid/grid_fs'
require 'active_triples'

module Ladder::File
  extend ActiveSupport::Concern

  include ActiveTriples::Identifiable

  included do
    configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
  end

  delegate :_id, :id, to: :@file
  delegate *Mongoid::Atomic.instance_methods, to: :@file
  delegate *Mongoid::Changeable.instance_methods, to: :@file
  delegate *Mongoid::Document.instance_methods, to: :@file
  delegate *Mongoid::Relations.instance_methods, to: :@file
  delegate *Mongoid::Stateful.instance_methods, to: :@file
  delegate *Mongoid::Traversable.instance_methods, to: :@file
  delegate *Mongoid::Validatable.instance_methods, to: :@file
=begin
  def compact
    self
  end

  def map(&block)
    yield self
  end
=end  
  ##
  # Make constructor as ActiveModel-like as possible
  #
  # eg. Ladder::File.new(StringIO.new)
  #     Ladder::File.new(data: '... binary data ...')
  #
  def initialize(*args)
    if args.first.is_a? Hash
      self.data = args.first[:data].to_s
    else
      @readable = args.first
    end

    @file = @readable.respond_to?(:data) ? @readable : self.class.grid::File.new
  end
  
  ##
  # Make save behave like Mongoid::Document as much as possible
  def save
    # TODO: clean up logic here
    return false if @readable.nil? or 0 == @readable.size
    @file.persisted? ? @file.save : !! @file = self.class.grid.put(@readable)
  end

  ##
  # Output content of object from stored file or readable input
  def data(*opts)
    @file.persisted? ? @file.data(*opts) : @readable.read
  end
  
  ##
  # Allow setting data on existing object
  def data=(string)
    @readable = StringIO.new(string)
  end

  module ClassMethods

    delegate :all, :all_of, :relations, :where, to: :'grid::File'
    delegate *Mongoid::Relations::Reflections.instance_methods(false), to: :'grid::File'
    delegate *Mongoid::Relations::Referenced::Many.methods(false), to: :'grid::File'

    ##
    # Create a namespaced GridFS module for this class
    def grid
     @grid ||= Mongoid::GridFs.build_namespace_for name
    end
    
    ##
    # Behave like Mongoid::Document as much as possible
    def find(*args)
      id = args.shift unless args.first.is_a? Hash
      file = id ? grid.get(id) : grid.find(*args)

      self.new(file)
    end

  end

end