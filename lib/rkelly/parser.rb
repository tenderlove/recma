require 'rkelly/tokenizer'
require 'rkelly/generated_parser'

module RKelly
  class Parser < RKelly::GeneratedParser
    TOKENIZER = Tokenizer.new
    attr_accessor :logger
    def initialize
      @tokens = []
      @logger = nil
      @terminator = false
      @prev_token = nil
    end

    # Parse +javascript+ and return an AST
    def parse(javascript)
      @tokens = TOKENIZER.tokenize(javascript)
      @position = 0
      do_parse
    end

    private
    def on_error(error_token_id, error_value, value_stack)
      if logger
        logger.error(token_to_str(error_token_id))
        logger.error("error value: #{error_value}")
        logger.error("error stack: #{value_stack}")
      end
    end

    def next_token
      @terminator = false
      begin
        return [false, false] if @position >= @tokens.length
        n_token = @tokens[@position]
        @position += 1
        case @tokens[@position - 1][0]
        when :COMMENT
          @terminator = true if n_token[1] =~ /^\/\//
        when :S
          @terminator = true if n_token[1] =~ /[\r\n]/
        end
      end while([:COMMENT, :S].include?(n_token[0]))

      if @terminator &&
          ((@prev_token && %w[continue break return throw].include?(@prev_token[1])) ||
           (n_token && %w[++ --].include?(n_token[1])))
        @position -= 1
        return (@prev_token = [';', ';'])
      end

      @prev_token = n_token
    end
  end
end
