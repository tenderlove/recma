require File.dirname(__FILE__) + "/helper"

class ResolveNodeTest < NodeTestCase
  def test_to_sexp
    node = ResolveNode.new('foo')
    assert_sexp [:resolve, 'foo'], node
  end
end
