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

  def test_null_to_string
    @runtime.execute("
                     MYOB = new Object(null);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Object]', MYOB.toString());
                     ")
  end

  def test_void_0_typeof
    js_assert_equal("'object'", "typeof new Object(void 0)")
  end

  def test_void_0_to_string
    @runtime.execute("
                     MYOB = new Object(void 0);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Object]', MYOB.toString());
                     ")
  end

  def test_string_typeof
    js_assert_equal("'object'", "typeof new Object('string')")
  end

  def test_string_value_of
    js_assert_equal("'string'", "(new Object('string')).valueOf()")
  end

  def test_string_to_string
    @runtime.execute("
                     MYOB = new Object('string');
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object String]', MYOB.toString());
                     ")
  end

  def test_empty_string_typeof
    js_assert_equal("'object'", "typeof new Object('')")
  end

  def test_empty_string_value_of
    js_assert_equal("''", "(new Object('')).valueOf()")
  end

  def test_empty_string_to_string
    @runtime.execute("
                     MYOB = new Object('');
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object String]', MYOB.toString());
                     ")
  end

  def test_nan_typeof
    js_assert_equal("'object'", "typeof new Object(Number.NaN)")
  end

  def test_nan_value_of
    js_assert_equal("Number.NaN", "(new Object(Number.NaN)).valueOf()")
  end

  def test_nan_to_string
    @runtime.execute("
                     MYOB = new Object(Number.NaN);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  def js_assert_equal(expected, actual)
    @runtime.execute("assert_equal(#{expected}, #{actual});")
  end
end
