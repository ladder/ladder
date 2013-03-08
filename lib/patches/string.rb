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
    self.match(URI.regexp(schemes))
  end
end