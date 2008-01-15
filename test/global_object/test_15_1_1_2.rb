require File.dirname(__FILE__) + "/../helper"

# ECMA-262
# Section 15.1.1.2
class GlobalObject_15_1_1_2_Test < Test::Unit::TestCase
  def setup
    @runtime = RKelly::Runtime.new
    @runtime.define_function(:assert_equal) do |*args|
      assert_equal(*args)
    end
  end

  def test_global_nan
    js_assert_equal('Number.POSITIVE_INFINITY', 'Infinity')
  end

  def test_this_nan
    js_assert_equal('Number.POSITIVE_INFINITY', 'this.Infinity')
  end

  def test_typeof_nan
    js_assert_equal("'number'", 'typeof Infinity')
  end

  def js_assert_equal(expected, actual)
    @runtime.execute("assert_equal(#{expected}, #{actual});")
  end
end
