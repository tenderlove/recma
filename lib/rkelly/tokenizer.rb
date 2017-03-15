require 'rkelly/lexeme'
require 'strscan'

module RKelly
  class Tokenizer
    KEYWORDS = %w{
      break case catch continue default delete do else finally for function
      if in instanceof new return switch this throw try typeof var void while
      with

      const true false null debugger
    }

    RESERVED = %w{
      abstract boolean byte char class double enum export extends
      final float goto implements import int interface long native package
      private protected public short static super synchronized throws
      transient volatile
    }

    LITERALS = {
      # Punctuators
      '=='  => :EQEQ,
      '!='  => :NE,
      '===' => :STREQ,
      '!==' => :STRNEQ,
      '<='  => :LE,
      '>='  => :GE,
      '||'  => :OR,
      '&&'  => :AND,
      '++'  => :PLUSPLUS,
      '--'  => :MINUSMINUS,
      '<<'  => :LSHIFT,
      '<<=' => :LSHIFTEQUAL,
      '>>'  => :RSHIFT,
      '>>=' => :RSHIFTEQUAL,
      '>>>' => :URSHIFT,
      '>>>='=> :URSHIFTEQUAL,
      '&='  => :ANDEQUAL,
      '%='  => :MODEQUAL,
      '^='  => :XOREQUAL,
      '|='  => :OREQUAL,
      '+='  => :PLUSEQUAL,
      '-='  => :MINUSEQUAL,
      '*='  => :MULTEQUAL,
      '/='  => :DIVEQUAL,
    }

    # Some keywords can be followed by regular expressions (eg, return and throw).
    # Others can be followed by division.
    KEYWORDS_THAT_IMPLY_DIVISION = %w{
      this true false null
    }

    KEYWORDS_THAT_IMPLY_REGEX = KEYWORDS - KEYWORDS_THAT_IMPLY_DIVISION

    SINGLE_CHARS_THAT_IMPLY_DIVISION = [')', ']', '}']

    def initialize(&block)
      @lexemes = []

      # The lexemes are added in such order that the most often
      # occuring ones like whitespace, identifiers and strings are
      # listed before the less frequent ones.
      #
      # At the same time the order is also such, that we only need to
      # look for the first matching lexeme.

      token(:S, /\A[\s\r\n]+/m)

      # For these chars we can be sure of that we're looking at a
      # :SINGLE_CHAR token.
      token(:SINGLE_CHAR, /\A[,:;(){}\[\]]/) do |type, value|
        [value, value]
      end

      token(:RAW_IDENT, /\A([_\$A-Za-z][_\$0-9A-Za-z]*)/) do |type,value|
        if KEYWORDS.include?(value)
          [value.upcase.to_sym, value]
        elsif RESERVED.include?(value)
          [:RESERVED, value]
        else
          [:IDENT, value]
        end
      end

      token(:STRING, /\A"(?:[^"\\]*(?:\\.[^"\\]*)*)"|\A'(?:[^'\\]*(?:\\.[^'\\]*)*)'/m)

      token(:COMMENT, /\A\/(?:\*(?:.)*?\*\/|\/[^\n]*)/m)

      # A regexp to match floating point literals (but not integer literals).
      token(:NUMBER, /\A\d+\.\d*(?:[eE][-+]?\d+)?|\A\d+(?:\.\d*)?[eE][-+]?\d+|\A\.\d+(?:[eE][-+]?\d+)?/m) do |type, value|
        value.gsub!(/\.(\D)/, '.0\1') if value =~ /\.\w/
        value.gsub!(/\.$/, '.0') if value =~ /\.$/
        value.gsub!(/^\./, '0.') if value =~ /^\./
        [type, eval(value)]
      end
      token(:NUMBER, /\A0[xX][\da-fA-F]+|\A0[0-7]*|\A\d+/) do |type, value|
        [type, eval(value)]
      end

      # To distinguish regular expressions from comments, we require that
      # regular expressions start with a non * character (ie, not look like
      # /*foo*/). Note that we can't depend on the length of the match to
      # correctly distinguish, since `/**/i` is longer if matched as a regular
      # expression than as matched as a comment.
      # Incidentally, we're also not matching empty regular expressions
      # (eg, // and //g). Here we could depend on match length and priority to
      # determine that these are actually comments, but it turns out to be
      # easier to not match them in the first place.
      token(:REGEXP, /\A\/(?:[^\/\r\n\\*]|\\[^\r\n])[^\/\r\n\\]*(?:\\[^\r\n][^\/\r\n\\]*)*\/[gim]*/)

      token(:LITERALS,
        Regexp.new(LITERALS.keys.sort_by { |x|
          x.length
        }.reverse.map { |x| "\\A#{x.gsub(/([|+*^])/, '\\\\\1')}" }.join('|')
      )) do |type, value|
        [LITERALS[value], value]
      end

      token(:SINGLE_CHAR, /\A./) do |type, value|
        [value, value]
      end

    end

    def tokenize(string)
      raw_tokens(string).map { |x| x.to_racc_token }
    end

    def raw_tokens(string)
      scanner = StringScanner.new(string)
      tokens = []
      line_number = 1
      accepting_regexp = true
      while !scanner.eos?
        token = match_lexeme(scanner, accepting_regexp)

        if token.name != :S
          accepting_regexp = followable_by_regex(token)
        end

        token.line = line_number
        line_number += token.value.scan(/\n/).length
        scanner.pos += token.value.length
        tokens << token
      end
      tokens
    end

    # Returns the token of the first matching lexeme
    def match_lexeme(scanner, accepting_regexp)
      @lexemes.each do |lexeme|
        next if lexeme.name == :REGEXP && !accepting_regexp

        token = lexeme.match(scanner)
        return token if token
      end
    end

    private
    def token(name, pattern = nil, &block)
      @lexemes << Lexeme.new(name, pattern, &block)
    end

    def followable_by_regex(current_token)
      case current_token.name
      when :RAW_IDENT
        KEYWORDS_THAT_IMPLY_REGEX.include?(current_token.value)
      when :NUMBER
        false
      when :SINGLE_CHAR
        !SINGLE_CHARS_THAT_IMPLY_DIVISION.include?(current_token.value)
      else
        true
      end
    end
  end
end
