require File.dirname(__FILE__) + "/helper"

class PointcutVisitorTest < Test::Unit::TestCase
  include RKelly::Visitors

  def setup
    @parser = RKelly::Parser.new
  end

  def test_visit_NumberNode
    ast = @parser.parse('Element.update(10, 10)')
    assert_equal(2, ast.pointcut('10').matches.length)
  end

  def test_visit_RegexpNode
    ast = @parser.parse('Element.update(/asdf/, /asdf/)')
    assert_equal(2, ast.pointcut('/asdf/').matches.length)
  end
end
