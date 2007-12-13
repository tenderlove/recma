module RKelly
  class Lexeme
    def initialize(name, pattern, &block)
      @name     = name
      @pattern  = pattern
      @block    = block
    end
  end
end
