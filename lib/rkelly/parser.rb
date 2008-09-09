require 'rkelly/tokenizer'
require 'rkelly/generated_parser'


module RKelly
  class Parser < RKelly::GeneratedParser
    TOKENIZER = Tokenizer.new

    RKelly::GeneratedParser.instance_methods.each do |im|
      next unless im.to_s =~ /^_reduce_\d+$/
      eval(<<-eoawesomehack)
        def #{im}(val, _values, result)
          r = super(val.map { |v|
              v.is_a?(Token) ? v.to_racc_token[1] : v
            }, _values, result)
          if token = val.find { |v| v.is_a?(Token) }
            r.line = token.line if r.respond_to?(:line)
          end
          r
        end
      eoawesomehack
    end

    attr_accessor :logger
    def initialize
      @tokens = []
      @logger = nil
      @terminator = false
      @prev_token = nil
      @comment_stack = []
    end

    # Parse +javascript+ and return an AST
    def parse(javascript)
      @tokens = TOKENIZER.raw_tokens(javascript)
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
        case @tokens[@position - 1].name
        when :COMMENT
          @comment_stack << n_token
          @terminator = true if n_token.value =~ /^\/\//
        when :S
          @terminator = true if n_token.value =~ /[\r\n]/
        end
      end while([:COMMENT, :S].include?(n_token.name))

      if @terminator &&
          ((@prev_token && %w[continue break return throw].include?(@prev_token.value)) ||
           (n_token && %w[++ --].include?(n_token.value)))
        @position -= 1
        return (@prev_token = RKelly::Token.new(';', ';')).to_racc_token
      end

      @prev_token = n_token
      v = n_token.to_racc_token
      v[1] = n_token
      v
    end
  end
end
