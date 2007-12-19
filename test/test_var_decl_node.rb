require File.dirname(__FILE__) + "/helper"

class VarDeclNodeTest < NodeTestCase
  def test_to_sexp
    initializer = AssignExprNode.new(NumberNode.new(10))
    node = VarDeclNode.new('foo', initializer)
    assert_sexp [:var_decl, :foo, [:assign, [:lit, 10]]], node.to_sexp
  end
end
