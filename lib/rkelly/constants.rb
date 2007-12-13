module RKelly
TOKENS = [
  # End of source.
  "END",
  
  # Operators and punctuators.  Some pair-wise order matters, e.g. (+, -)
  # and (UNARY_PLUS, UNARY_MINUS).
  "\n", ";",
  ",",
  "=",
  "?", ":", "CONDITIONAL",
  "||",
  "&&",
  "|",
  "^",
  "&",
  "==", "!=", "===", "!==",
  "<", "<=", ">=", ">",
  "<<", ">>", ">>>",
  "+", "-",
  "*", "/", "%",
  "!", "~", "UNARY_PLUS", "UNARY_MINUS",
  "++", "--",
  ".",
  "[", "]",
  "{", "}",
  "(", ")",
  
  # Nonterminal tree node type codes.
  "SCRIPT", "BLOCK", "LABEL", "FOR_IN", "CALL", "NEW_WITH_ARGS", "INDEX",
  "ARRAY_INIT", "OBJECT_INIT", "PROPERTY_INIT", "GETTER", "SETTER",
  "GROUP", "LIST",
  
  # Terminals.
  "IDENTIFIER", "NUMBER", "STRING", "REGEXP",
  
  # Keywords.
  "break",
  "case", "catch", "const", "continue",
  "debugger", "default", "delete", "do",
  "else", "enum",
  "false", "finally", "for", "function",
  "if", "in", "instanceof",
  "new", "null",
  "return",
  "switch",
  "this", "throw", "true", "try", "typeof",
  "var", "void",
  "while", "with",
]

# Operator and punctuator mapping from token to tree node type name.
OPTYPENAMES = {
  "\n"  => "NEWLINE",
  ';'   => "SEMICOLON",
  ','   => "COMMA",
  '?'   => "HOOK",
  ':'   => "COLON",
  '||'  => "OR",
  '&&'  => "AND",
  '|'   => "BITWISE_OR",
  '^'   => "BITWISE_XOR",
  '&'   => "BITWISE_AND",
  '===' => "STRICT_EQ",
  '=='  => "EQ",
  '='   => "ASSIGN",
  '!==' => "STRICT_NE",
  '!='  => "NE",
  '<<'  => "LSH",
  '<='  => "LE",
  '<'   => "LT",
  '>>>' => "URSH",
  '>>'  => "RSH",
  '>='  => "GE",
  '>'   => "GT",
  '++'  => "INCREMENT",
  '--'  => "DECREMENT",
  '+'   => "PLUS",
  '-'   => "MINUS",
  '*'   => "MUL",
  '/'   => "DIV",
  '%'   => "MOD",
  '!'   => "NOT",
  '~'   => "BITWISE_NOT",
  '.'   => "DOT",
  '['   => "LEFT_BRACKET",
  ']'   => "RIGHT_BRACKET",
  '{'   => "LEFT_CURLY",
  '}'   => "RIGHT_CURLY",
  '('   => "LEFT_PAREN",
  ')'   => "RIGHT_PAREN"
}

# Hash of keyword identifier to tokens index.
KEYWORDS = {}

# Define const END, etc., based on the token names.  Also map name to index.
CONSTS = {}

TOKENS.each_with_index do |t,i|
  if /\A[a-z]/ =~ t
    CONSTS[t.upcase] = i
    KEYWORDS[t] = i
  elsif /\A\W/ =~ t
    CONSTS[OPTYPENAMES[t]] = i
  else
    CONSTS[t] = i
  end
end

# Map assignment operators to their indexes in the tokens array.
ASSIGNOPS = ['|', '^', '&', '<<', '>>', '>>>', '+', '-', '*', '/', '%']
ASSIGNOPSHASH = {}

ASSIGNOPS.length.times do |i|
  t = ASSIGNOPS[i]
  ASSIGNOPSHASH[t] = CONSTS[OPTYPENAMES[t]]
end

OPPRECEDENCE = {
  "SEMICOLON" => 0,
  "COMMA" => 1,
  "ASSIGN" => 2,
  "HOOK" => 3, "COLON" => 3, "CONDITIONAL" => 3,
  "OR" => 4,
  "AND" => 5,
  "BITWISE_OR" => 6,
  "BITWISE_XOR" => 7,
  "BITWISE_AND" => 8,
  "EQ" => 9, "NE" => 9, "STRICT_EQ" => 9, "STRICT_NE" => 9,
  "LT" => 10, "LE" => 10, "GE" => 10, "GT" => 10, "IN" => 10, "INSTANCEOF" => 10,
  "LSH" => 11, "RSH" => 11, "URSH" => 11,
  "PLUS" => 12, "MINUS" => 12,
  "MUL" => 13, "DIV" => 13, "MOD" => 13,
  "DELETE" => 14, "VOID" => 14, "TYPEOF" => 14, # PRE_INCREMENT: 14, PRE_DECREMENT: 14,
  "NOT" => 14, "BITWISE_NOT" => 14, "UNARY_PLUS" => 14, "UNARY_MINUS" => 14,
  "INCREMENT" => 15, "DECREMENT" => 15, # postfix
  "NEW" => 16,
  "DOT" => 17
}

# Map operator type code to precedence.
OPPRECEDENCE.keys.each do |i|
  OPPRECEDENCE[CONSTS[i]] = OPPRECEDENCE[i]
end

OPARITY = {
  "COMMA" => -2,
  "ASSIGN" => 2,
  "CONDITIONAL" => 3,
  "OR" => 2,
  "AND" => 2,
  "BITWISE_OR" => 2,
  "BITWISE_XOR" => 2,
  "BITWISE_AND" => 2,
  "EQ" => 2, "NE" => 2, "STRICT_EQ" => 2, "STRICT_NE" => 2,
  "LT" => 2, "LE" => 2, "GE" => 2, "GT" => 2, "IN" => 2, "INSTANCEOF" => 2,
  "LSH" => 2, "RSH" => 2, "URSH" => 2,
  "PLUS" => 2, "MINUS" => 2,
  "MUL" => 2, "DIV" => 2, "MOD" => 2,
  "DELETE" => 1, "VOID" => 1, "TYPEOF" => 1, # PRE_INCREMENT: 1, PRE_DECREMENT: 1,
  "NOT" => 1, "BITWISE_NOT" => 1, "UNARY_PLUS" => 1, "UNARY_MINUS" => 1,
  "INCREMENT" => 1, "DECREMENT" => 1,   # postfix
  "NEW" => 1, "NEW_WITH_ARGS" => 2, "DOT" => 2, "INDEX" => 2, "CALL" => 2,
  "ARRAY_INIT" => 1, "OBJECT_INIT" => 1, "GROUP" => 1
}

# Map operator type code to arity.
OPARITY.keys.each do |i|
  OPARITY[CONSTS[i]] = OPARITY[i]
end


opregexpsrc = "\\A"
# NB: superstring tokens (e.g., ++) must come before their substring token
# counterparts (+ in the example), so that the OPREGEXP regular expression
# synthesized from this list makes the longest possible match.
[';', ',', '?', ':', '||', '&&', '|', '^', '&', '===', '==', '=', '!==',
  '!=', '<<', '<=', '<', '>>>', '>>', '>=', '>', '++', '--', '+', '-', '*',
  '/', '%', '!', '~', '.', '[', ']', '{', '}', '(', ')'].each do |op|
  opregexpsrc += "|\\A" if opregexpsrc != "\\A"
  opregexpsrc += op.gsub(/([?|^&(){}\[\]+\-*\/\.])/) {|s| "\\" + s}
end

# Build a regexp that recognizes operators and punctuators (except newline).
OPREGEXP = Regexp.new(opregexpsrc, Regexp::MULTILINE)


# A regexp to match floating point literals (but not integer literals).
FPREGEXP = Regexp.new("\\A\\d+\\.\\d*(?:[eE][-+]?\\d+)?|\\A\\d+(?:\\.\\d*)?[eE][-+]?\\d+|\\A\\.\\d+(?:[eE][-+]?\\d+)?", Regexp::MULTILINE)

DECLARED_FORM = 0
EXPRESSED_FORM = 1
STATEMENT_FORM = 2
end
