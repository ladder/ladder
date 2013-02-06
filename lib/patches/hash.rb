class Hash
  def to_string_recursive
    self.recurse do |h|
      h.inject('') do |string, (key, values)|
        if values.is_a? Array
          string += values.join
        else
          string += values
        end
      end
    end
  end
end