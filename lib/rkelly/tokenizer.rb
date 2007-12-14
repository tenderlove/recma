require 'rkelly/constants'
require 'rkelly/lexeme'

module RKelly
  class Tokenizer
    KEYWORDS = [ "break", "case", "catch", "const", "continue",
          "debugger", "default", "delete", "do", "else", "enum",
          "false", "finally", "for", "function",
          "if", "in", "instanceof", "new", "null", "return",
          "switch", "this", "throw", "true", "try", "typeof",
          "var", "void", "while", "with" ]

    def initialize(&block)
      @lexemes = []

      token(:COMMENT, /\A\/(?:\*(?:.)*?\*\/|\/[^\n]*)/m)
      token(:STRING, /\A"(?:\\.|[^"])*"|\A'(?:[^']|\\.)*'/m)

      # A regexp to match floating point literals (but not integer literals).
      token(:NUMBER, Regexp.new("\\A\\d+\\.\\d*(?:[eE][-+]?\\d+)?|\\A\\d+(?:\\.\\d*)?[eE][-+]?\\d+|\\A\\.\\d+(?:[eE][-+]?\\d+)?", Regexp::MULTILINE))
      token(:NUMBER, /\A0[xX][\da-fA-F]+|\A0[0-7]*|\A\d+/)

      token(:IDENTIFIER, /\A(\w|\$)+/) do |type,value|
        if KEYWORDS.include?(value)
          [value.upcase.to_sym, value]
        else
          [type, value]
        end
      end

      token(:REGEXP, /\A\/((?:\\.|[^\/])+)\/([gi]*)/m)
      token(:S, /\A[\s\r\n]*/m)

    end
  
    def get
      #while @lookahead > 0
      #  @lookahead -= 1
      #  @tokenIndex = (@tokenIndex + 1) & 3
      #  token = @tokens[@tokenIndex]
      #  return token.type if token.type != CONSTS["NEWLINE"] || @scanNewlines
      #end
      #
      #while true
      #  input = self.input
  
      #  if @scanNewlines
      #    match = /\A[ \t]+/.match(input)
      #  else
      #    match = /\A\s+/.match(input)
      #  end
      #  
      #  if match
      #    spaces = match[0]
      #    @cursor += spaces.length
      #    @lineno += spaces.count("\n")
      #    input = self.input
      #  end
      #  
      #  match = /\A\/(?:\*(?:.)*?\*\/|\/[^\n]*)/m.match(input)
      #  break unless match
      #  comment = match[0]
      #  @cursor += comment.length
      #  @lineno += comment.count("\n")
      #end
      #
      ##puts input
      #
      #@tokenIndex = (@tokenIndex + 1) & 3
      #token = @tokens[@tokenIndex]
      #(@tokens[@tokenIndex] = token = Token.new) unless token
      #if input.length == 0
      #  #puts "end!!!"
      #  return (token.type = CONSTS["END"])
      #end
  
      #cursor_advance = 0
      #elsif (match = /\A(\w|\$)+/.match(input))
      #  id = match[0]
      #  token.type = KEYWORDS[id] || CONSTS["IDENTIFIER"]
      #  token.value = id
      #elsif (match = /\A"(?:\\.|[^"])*"|\A'(?:[^']|\\.)*'/.match(input))
      #  token.type = CONSTS["STRING"]
      #  token.value = match[0].to_s
      #elsif @scanOperand and (match = /\A\/((?:\\.|[^\/])+)\/([gi]*)/.match(input))
      #  token.type = CONSTS["REGEXP"]
      #  token.value = Regexp.new(match[1], match[2])
      #elsif (match = OPREGEXP.match(input))
      #  op = match[0]
      #  if ASSIGNOPSHASH[op] && input[op.length, 1] == '='
      #    token.type = CONSTS["ASSIGN"]
      #    token.assignOp = CONSTS[OPTYPENAMES[op]]
      #    cursor_advance = 1 # length of '='
      #  else
      #    #puts CONSTS[OPTYPENAMES[op]].to_s + " " + OPTYPENAMES[op] + " " + op
      #    token.type = CONSTS[OPTYPENAMES[op]]
      #    if @scanOperand and (token.type == CONSTS["PLUS"] || token.type == CONSTS["MINUS"])
      #      token.type += CONSTS["UNARY_PLUS"] - CONSTS["PLUS"]
      #    end
      #    token.assignOp = nil
      #  end
      #  token.value = op
      #else
      #  raise SyntaxError.new("Illegal token", self)
      #end
  
      #token.start = @cursor
      #@cursor += match[0].length + cursor_advance
      #token.end = @cursor
      #token.lineno = @lineno
      #
      #return token.type
    end

    def tokenize(string)
      tokens = []
      while string.length > 0
        longest_token = nil

        @lexemes.each { |lexeme|
          match = lexeme.match(string)
          next if match.nil?
          longest_token = match if longest_token.nil?
          next if longest_token.value.length >= match.value.length
          longest_token = match
        }

        string = string.slice(Range.new(longest_token.value.length, -1))
        tokens << longest_token unless longest_token.name == :S
      end
      tokens.map { |x| x.to_racc_token }
    end
  
    private
    def token(name, pattern = nil, &block)
      @lexemes << Lexeme.new(name, pattern, &block)
    end
  end
end
