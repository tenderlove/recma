require File.dirname(__FILE__) + "/helper"

class NumberNodeTest < Test::Unit::TestCase
  include RKelly::Nodes

  def test_to_sexp
    node = NumberNode.new(10)
    assert node
    assert_equal [:lit, 10], node.to_sexp
  end
end
