require File.dirname(__FILE__) + "/../helper"

class Object_15_2_2_1_Test < Test::Unit::TestCase
  def setup
    @runtime = RKelly::Runtime.new
    @runtime.define_function(:assert_equal) do |*args|
      assert_equal(*args)
    end
  end

  def test_null_typeof
    js_assert_equal("'object'", "typeof new Object(null)")
  end

  def js_assert_equal(expected, actual)
    @runtime.execute("assert_equal(#{expected}, #{actual});")
  end
end
