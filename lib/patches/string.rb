class String
  def normalize(opts={})
    space_char = opts[:space_char] || ''
    self.gsub(/[-+!\(\)\{\}\[\]\n\s^"'~*?:;,.\\\/]|&&|\|\|/, space_char).squeeze(space_char).strip rescue self
  end

  def normalize!(opts={})
    space_char = opts[:space_char] || ''
    self.gsub!(/[-+!\(\)\{\}\[\]\n\s^"'~*?:;,.\\\/]|&&|\|\|/, space_char).squeeze!(space_char).strip! rescue nil
  end

  def -(other)
    self.index(other) == 0 ? self[other.size..self.size] : nil
  end

  def is_uri?(schemes = ['http', 'https'])
    match = self.match(URI.regexp(schemes))
    return (0 == match.begin(0) and self.size == match.end(0)) if match
    false
  end

  def from_dot_notation
    arr = self.split('.')
    {arr.first.to_sym => arr.last.to_sym}
  end
end