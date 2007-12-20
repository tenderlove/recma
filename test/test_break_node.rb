require File.dirname(__FILE__) + "/helper"

class BreakNodeTest < NodeTestCase
  def test_to_sexp
    node = BreakNode.new(nil)
    assert_sexp([:break], node.to_sexp)

    node = BreakNode.new('foo')
    assert_sexp([:break, 'foo'], node.to_sexp)
  end
end
