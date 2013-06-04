require 'rkelly/token'

module RKelly
  class Lexeme
    attr_reader :name, :pattern
    def initialize(name, pattern, &block)
      @name       = name
      @pattern    = pattern
      @block      = block
    end

    def match(scanner)
      match = scanner.check(pattern)
      return Token.new(name, match.to_s, &@block) if match
      match
    end
  end
end
