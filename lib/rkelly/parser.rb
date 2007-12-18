require 'rkelly/tokenizer'
require 'rkelly/generated_parser'

module RKelly
  class Parser < RKelly::GeneratedParser
    TOKENIZER = Tokenizer.new
    def initialize
      @tokens = []
      @logger = nil
    end

    # Parse +javascript+ and return an AST
    def parse(javascript)
      @tokens = TOKENIZER.tokenize(javascript)
      @position = 0
      do_parse
    end

    private
    def next_token
      return [false, false] if @position >= @tokens.length
      n_token = @tokens[@position]
      @position += 1
      n_token
    end
  end
end
