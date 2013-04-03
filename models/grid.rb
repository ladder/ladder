class Grid

  attr_reader :path

  def initialize(*args)
    @file = Mongoid::GridFS.file_model.new(*args)
  end

  %w( delete content_type length ).each do |method|
    class_eval <<-__
      def #{ method }(*args, &block)
        grid[@path].#{ method }(*args, &block) if grid[@path]
      end
    __
  end

#  protected

  class << self; attr_accessor :grid end

  self.grid = ::Mongoid::GridFS

  def grid
    self.class.grid
  end

end