class Hash
  def to_string_recursive
    self.recurse do |h|
      h.inject('') do |string, (key, values)|
        values.is_a?(Array) ? string += values.join : string += values.to_s
      end
    end
  end
end