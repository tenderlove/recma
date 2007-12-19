require File.dirname(__FILE__) + "/helper"

class SourceElementListTest < NodeTestCase
  def test_to_sexp
    num = NumberNode.new(10)
    node = SourceElementList.new([num, num])
    assert_sexp [[:lit, 10], [:lit, 10]], node.to_sexp
  end
end
