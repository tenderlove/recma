require 'rkelly/constants'

class RKelly
  class Tokenizer
    attr_accessor :cursor, :source, :tokens, :tokenIndex, :lookahead
    attr_accessor :scanNewlines, :scanOperand, :filename, :lineno
  
    def initialize(source, line)
      @cursor = 0
      @source = source.to_s
      @tokens = []
      @tokenIndex = 0
      @lookahead = 0
      @scanNewlines = false
      @scanOperand = true
      @lineno = line or 1
    end
  
    def input
      return @source.slice(@cursor, @source.length - @cursor)
    end
  
    def done
      return self.peek == CONSTS["END"];
    end
  
    def token
      return @tokens[@tokenIndex];
    end
    
    def match (tt)
      got = self.get
      #puts got
      #puts tt
      return got == tt || self.unget
    end
    
    def mustMatch (tt)
      raise SyntaxError.new("Missing " + TOKENS[tt].downcase, self) unless self.match(tt)
      return self.token
    end
  
    def peek
      if @lookahead > 0
        #tt = @tokens[(@tokenIndex + @lookahead)].type
        tt = @tokens[(@tokenIndex + @lookahead) & 3].type
      else
        tt = self.get
        self.unget
      end
      return tt
    end
    
    def peekOnSameLine
      @scanNewlines = true;
      tt = self.peek
      @scanNewlines = false;
      return tt
    end
  
    def get
      while @lookahead > 0
        @lookahead -= 1
        @tokenIndex = (@tokenIndex + 1) & 3
        token = @tokens[@tokenIndex]
        return token.type if token.type != CONSTS["NEWLINE"] || @scanNewlines
      end
      
      while true
        input = self.input
  
        if @scanNewlines
          match = /\A[ \t]+/.match(input)
        else
          match = /\A\s+/.match(input)
        end
        
        if match
          spaces = match[0]
          @cursor += spaces.length
          @lineno += spaces.count("\n")
          input = self.input
        end
        
        match = /\A\/(?:\*(?:.)*?\*\/|\/[^\n]*)/m.match(input)
        break unless match
        comment = match[0]
        @cursor += comment.length
        @lineno += comment.count("\n")
      end
      
      #puts input
      
      @tokenIndex = (@tokenIndex + 1) & 3
      token = @tokens[@tokenIndex]
      (@tokens[@tokenIndex] = token = Token.new) unless token
      if input.length == 0
        #puts "end!!!"
        return (token.type = CONSTS["END"])
      end
  
      cursor_advance = 0
      if (match = FPREGEXP.match(input))
        token.type = CONSTS["NUMBER"]
        token.value = match[0].to_f
      elsif (match = /\A0[xX][\da-fA-F]+|\A0[0-7]*|\A\d+/.match(input))
        token.type = CONSTS["NUMBER"]
        token.value = match[0].to_i
      elsif (match = /\A(\w|\$)+/.match(input))
        id = match[0]
        token.type = KEYWORDS[id] || CONSTS["IDENTIFIER"]
        token.value = id
      elsif (match = /\A"(?:\\.|[^"])*"|\A'(?:[^']|\\.)*'/.match(input))
        token.type = CONSTS["STRING"]
        token.value = match[0].to_s
      elsif @scanOperand and (match = /\A\/((?:\\.|[^\/])+)\/([gi]*)/.match(input))
        token.type = CONSTS["REGEXP"]
        token.value = Regexp.new(match[1], match[2])
      elsif (match = OPREGEXP.match(input))
        op = match[0]
        if ASSIGNOPSHASH[op] && input[op.length, 1] == '='
          token.type = CONSTS["ASSIGN"]
          token.assignOp = CONSTS[OPTYPENAMES[op]]
          cursor_advance = 1 # length of '='
        else
          #puts CONSTS[OPTYPENAMES[op]].to_s + " " + OPTYPENAMES[op] + " " + op
          token.type = CONSTS[OPTYPENAMES[op]]
          if @scanOperand and (token.type == CONSTS["PLUS"] || token.type == CONSTS["MINUS"])
            token.type += CONSTS["UNARY_PLUS"] - CONSTS["PLUS"]
          end
          token.assignOp = nil
        end
        token.value = op
      else
        raise SyntaxError.new("Illegal token", self)
      end
  
      token.start = @cursor
      @cursor += match[0].length + cursor_advance
      token.end = @cursor
      token.lineno = @lineno
      
      return token.type
    end
  
    def unget
      @lookahead += 1
      raise SyntaxError.new("PANIC: too much lookahead!", self) if @lookahead == 4
      @tokenIndex = (@tokenIndex - 1) & 3
      return nil
    end
  end
end
