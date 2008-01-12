require File.dirname(__FILE__) + "/../helper"

class Object_15_2_1_1_Test < Test::Unit::TestCase
  def setup
    @runtime = RKelly::Runtime.new
    @runtime.define_function(:assert_equal) do |*args|
      assert_equal(*args)
    end
  end

  def test_null_value_of
    @runtime.execute("
                     var NULL_OBJECT = Object(null);
                     assert_equal(NULL_OBJECT, (NULL_OBJECT).valueOf());
                     ")
  end

  def test_null_type_of
    js_assert_equal("'object'", 'typeof (Object(null))')
  end

  def test_undefined_value_of
    @runtime.execute("
                     var UNDEF_OBJECT = Object(void 0);
                     assert_equal(UNDEF_OBJECT, (UNDEF_OBJECT).valueOf());
                     ")
  end

  def test_undefined_type_of
    js_assert_equal("'object'", 'typeof (Object(void 0))')
  end

  def test_true_type_of
    js_assert_equal("'object'", 'typeof (Object(true))')
  end

  def test_true_value_of
    js_assert_equal("true", 'Object(true).valueOf()')
  end

  def test_true_to_string
    @runtime.execute("
                     var MYOB = Object(true);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Boolean]', MYOB.toString());
                     ")
  end

  def test_false_value_of
    js_assert_equal("false", 'Object(false).valueOf()')
  end

  def test_false_type_of
    js_assert_equal("'object'", 'typeof (Object(false))')
  end

  def test_false_to_string
    @runtime.execute("
                     var MYOB = Object(false);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Boolean]', MYOB.toString());
                     ")
  end

  def test_0_value_of
    js_assert_equal("0", 'Object(0).valueOf()')
  end

  def test_0_type_of
    js_assert_equal("'object'", 'typeof Object(0)')
  end

  def test_0_to_string
    @runtime.execute("
                     var MYOB = Object(0);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  # Diverts from the ECMA.  In ECMA, -0 is -0, not 0
  def test_minus_0_value_of
    js_assert_equal("0", 'Object(-0).valueOf()')
  end

  def test_minus_0_type_of
    js_assert_equal("'object'", 'typeof Object(-0)')
  end

  def test_minus_0_to_string
    @runtime.execute("
                     var MYOB = Object(-0);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end
  ## END Diversion. ;-)

  def test_1_value_of
    js_assert_equal("1", 'Object(1).valueOf()')
  end

  def test_1_type_of
    js_assert_equal("'object'", 'typeof Object(1)')
  end

  def test_1_to_string
    @runtime.execute("
                     var MYOB = Object(1);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  def test_minus_1_value_of
    js_assert_equal("-1", 'Object(-1).valueOf()')
  end

  def test_minus_1_type_of
    js_assert_equal("'object'", 'typeof Object(-1)')
  end

  def test_minus_1_to_string
    @runtime.execute("
                     var MYOB = Object(-1);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  def test_number_max_value_of
    js_assert_equal("1.797693134862315e308", 'Object(Number.MAX_VALUE).valueOf()')
  end

  def test_number_max_type_of
    js_assert_equal("'object'", 'typeof Object(Number.MAX_VALUE)')
  end

  def test_number_max_to_string
    @runtime.execute("
                     var MYOB = Object(Number.MAX_VALUE);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  def test_number_min_value_of
    js_assert_equal("1.0e-306", 'Object(Number.MIN_VALUE).valueOf()')
  end

  def test_number_min_type_of
    js_assert_equal("'object'", 'typeof Object(Number.MIN_VALUE)')
  end

  def test_number_min_to_string
    @runtime.execute("
                     var MYOB = Object(Number.MIN_VALUE);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  def test_number_positive_infinity_value
    js_assert_equal(
      "Number.POSITIVE_INFINITY",
      'Object(Number.POSITIVE_INFINITY).valueOf()'
    )
  end

  def test_number_positive_infinity_type
    js_assert_equal("'object'", 'typeof Object(Number.POSITIVE_INFINITY)')
  end

  def test_number_positive_infinity_string
    @runtime.execute("
                     var MYOB = Object(Number.POSITIVE_INFINITY);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  def test_number_negative_infinity_value
    js_assert_equal(
      "Number.NEGATIVE_INFINITY",
      'Object(Number.NEGATIVE_INFINITY).valueOf()'
    )
  end

  def test_number_negative_infinity_type
    js_assert_equal("'object'", 'typeof Object(Number.NEGATIVE_INFINITY)')
  end

  def test_number_negative_infinity_string
    @runtime.execute("
                     var MYOB = Object(Number.NEGATIVE_INFINITY);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  def test_nan_value
    js_assert_equal("Number.NaN", 'Object(Number.NaN).valueOf()')
  end

  def test_number_nan_type
    js_assert_equal("'object'", 'typeof Object(Number.NaN)')
  end

  def test_number_nan_string
    @runtime.execute("
                     var MYOB = Object(Number.NaN);
                     MYOB.toString = Object.prototype.toString;
                     assert_equal('[object Number]', MYOB.toString());
                     ")
  end

  def js_assert_equal(expected, actual)
    @runtime.execute("assert_equal(#{expected}, #{actual});")
  end
end
