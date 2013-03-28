class Importer
  include ActiveSupport::DescendantsTracker

  # Return an instance of an appropriate importer for the given content type
  def self.create(content_type)
    descendants.each do |klass|
      return klass.new if klass.content_types.include? content_type
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