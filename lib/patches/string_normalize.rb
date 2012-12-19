class String
  def normalize(opts={})
    space_char = opts[:space_char] || ''
    self.gsub(/[-+!\(\)\{\}\[\]\n\s^"'~*?:;,.\\\/]|&&|\|\|/, space_char).strip rescue self
  end

  def normalize!(opts={})
    space_char = opts[:space_char] || ''
    self.gsub!(/[-+!\(\)\{\}\[\]\n\s^"'~*?:;,.\\\/]|&&|\|\|/, space_char).strip rescue nil
  end

  def -(other)
    self.index(other) == 0 ? self[other.size..self.size] : nil
  end
end