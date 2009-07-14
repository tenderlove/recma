require File.dirname(__FILE__) + "/helper"

class TokenizerTest < Test::Unit::TestCase
  def setup
    @tokenizer = RKelly::Tokenizer.new
  end

  def test_comments
    tokens = @tokenizer.tokenize("/** Fooo */")
    assert_tokens([[:COMMENT, '/** Fooo */']], tokens)
  end

  def test_string_single_quote
    tokens = @tokenizer.tokenize("foo = 'hello world';")
    assert_tokens([
                 [:IDENT, 'foo'],
                 ['=', '='],
                 [:STRING, "'hello world'"],
                 [';', ';'],
    ], tokens)
  end

  def test_string_double_quote
    tokens = @tokenizer.tokenize('foo = "hello world";')
    assert_tokens([
                 [:IDENT, 'foo'],
                 ['=', '='],
                 [:STRING, '"hello world"'],
                 [';', ';'],
    ], tokens)
  end

  def test_number_parse
    tokens = @tokenizer.tokenize('3.')
    assert_tokens([[:NUMBER, 3.0]], tokens)

    tokens = @tokenizer.tokenize('3.e1')
    assert_tokens([[:NUMBER, 30]], tokens)

    tokens = @tokenizer.tokenize('.001')
    assert_tokens([[:NUMBER, 0.001]], tokens)

    tokens = @tokenizer.tokenize('3.e-1')
    assert_tokens([[:NUMBER, 0.30]], tokens)
  end

  def test_identifier
    tokens = @tokenizer.tokenize("foo")
    assert_tokens([[:IDENT, 'foo']], tokens)
  end

  def test_ignore_identifier
    tokens = @tokenizer.tokenize("0foo")
    assert_tokens([[:NUMBER, 0], [:IDENT, 'foo']], tokens)
  end

  def test_increment
    tokens = @tokenizer.tokenize("foo += 1;")
    assert_tokens([
                 [:IDENT, 'foo'],
                 [:PLUSEQUAL, '+='],
                 [:NUMBER, 1],
                 [';', ';'],
    ], tokens)
  end

  def test_regex
    tokens = @tokenizer.tokenize("foo = /=asdf/;")
    assert_tokens([
                 [:IDENT, 'foo'],
                 ['=', '='],
                 [:REGEXP, '/=asdf/'],
                 [';', ';'],
    ], tokens)
  end

  def test_regular_expression_escape
    tokens = @tokenizer.tokenize('foo = /\/asdf/gi;')
    assert_tokens([
                 [:IDENT, 'foo'],
                 ['=', '='],
                 [:REGEXP, '/\/asdf/gi'],
                 [';', ';'],
    ], tokens)
  end

  def test_comment_assign
    tokens = @tokenizer.tokenize("foo = /**/;")
    assert_tokens([
                 [:IDENT, 'foo'],
                 ['=', '='],
                 [:COMMENT, '/**/'],
                 [';', ';'],
    ], tokens)

    tokens = @tokenizer.tokenize("foo = //;")
    assert_tokens([
                 [:IDENT, 'foo'],
                 ['=', '='],
                 [:COMMENT, '//;'],
    ], tokens)
  end

  def assert_tokens(expected, actual)
    assert_equal(expected, actual.select { |x| x[0] != :S })
  end

  %w{
    break case catch continue default delete do else finally for function
    if in instanceof new return switch this throw try typeof var void while 
    with 

    const true false null debugger
  }.each do |kw|
    define_method(:"test_keyword_#{kw}") do
      tokens = @tokenizer.tokenize(kw)
      assert_equal 1, tokens.length
      assert_equal([[kw.upcase.to_sym, kw]], tokens)
    end
  end
  {
    '=='  => :EQEQ,
    '!='  => :NE,
    '===' => :STREQ,
    '!==' => :STRNEQ,
    '<='   => :LE,
    '>='   => :GE,
    '||'  => :OR,
    '&&'  => :AND,
    '++'  => :PLUSPLUS,
    '--'  => :MINUSMINUS,
    '<<'  => :LSHIFT,
    '>>'  => :RSHIFT,
    '>>>' => :URSHIFT,
    '+='  => :PLUSEQUAL,
    '-='  => :MINUSEQUAL,
    '*='  => :MULTEQUAL,
    'null'  => :NULL,
    'true'  => :TRUE,
    'false' => :FALSE,
  }.each do |punctuator, sym|
    define_method(:"test_punctuator_#{sym}") do
      tokens = @tokenizer.tokenize(punctuator)
      assert_equal 1, tokens.length
      assert_equal([[sym, punctuator]], tokens)
    end
  end
end
