require File.dirname(__FILE__) + "/../helper"

class Expressions_11_9_1_Test < Test::Unit::TestCase
  def setup
    @runtime = RKelly::Runtime.new
  end

  def test_void_equal
    scope_chain = @runtime.execute("var x = void(0) == void(0);")
    assert scope_chain.has_property?('x')
    assert_equal true, scope_chain['x'].value
  end

  def test_void_equal_decl
    scope_chain = @runtime.execute("var x = 10; var y = 10; var z = x == y;")
    assert scope_chain.has_property?('z')
    assert_equal true, scope_chain['z'].value
  end
end
