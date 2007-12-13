require File.dirname(__FILE__) + "/helper"

class TokenizerTest < Test::Unit::TestCase
  def setup
    @tokenizer = RKelly::Tokenizer.new
  end

  def test_comments
    tokens = @tokenizer.tokenize("/** Fooo */")
    assert_equal 1, tokens.length
    assert_equal([[:COMMENT, '/** Fooo */']], tokens)
  end
end
