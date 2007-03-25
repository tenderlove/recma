class RKelly
  class SyntaxError < RuntimeError
    def initialize (msg, tokenizer)
      @msg = msg
      @tokenizer = tokenizer
    end

    def inspect
      "#{@msg} on line #{@tokenizer.lineno}"
    end
  end
end
