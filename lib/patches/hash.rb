class Hash
=begin
  attr_accessor :localized

  def localized?
    @localized || false
  end

  def localized=(bool)
    @localized = !! bool
  end
=end
  def to_string_recursive
    self.recurse do |h|
      h.inject('') do |string, (key, values)|
        if values.is_a? Array
          string += values.join
        else
          string += values.to_s
        end
      end
    end
  end
end