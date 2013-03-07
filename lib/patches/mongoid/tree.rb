module Mongoid
  module Tree
    def ancestors_and_self
      ancestors.reverse + [self]
    end
  end
end