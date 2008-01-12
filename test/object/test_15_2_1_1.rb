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

  def js_assert_equal(expected, actual)
    @runtime.execute("assert_equal(#{expected}, #{actual});")
  end
end
