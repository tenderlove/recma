require File.dirname(__FILE__) + "/helper"

class RuntimeTest < Test::Unit::TestCase
  def setup
    @runtime = RECMA::Runtime.new
  end

  def test_call_function
    @runtime.execute("function foo(a) { return a + 2; }")
    assert_equal(12, @runtime.call_function("foo", 10))
  end
end
