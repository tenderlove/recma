require File.dirname(__FILE__) + "/../helper"

class Object_11_3_1_Test < ECMAScriptTestCase
  def test_uninitialized
    @runtime.execute("var MYVAR; MYVAR++; assert_equal(NaN, MYVAR);")
  end

  def test_undefined
    @runtime.execute("var MYVAR= void 0; MYVAR++; assert_equal(NaN, MYVAR);")
  end

  @@tests = [
    :null   => [ 'null',  '0', '1'],
    :true   => [ 'true',  '1', '2'],
    :false  => [ 'false', '0', '1'],
    :positive_infinity  => [ 'Number.POSITIVE_INFINITY', 'Number.POSITIVE_INFINITY', 'Number.POSITIVE_INFINITY'],
    :negative_infinity  => [ 'Number.NEGATIVE_INFINITY', 'Number.NEGATIVE_INFINITY', 'Number.NEGATIVE_INFINITY'],
    :nan    => [ 'Number.NaN', 'Number.NaN', 'Number.NaN'],
    :zero   => [ '0', '0', '1'],
  ]

  def test_positive_float
    @runtime.execute("
                     var MYVAR=0.2345;
                     assert_equal(0.2345, MYVAR++);
                     assert_in_delta(0.2345, MYVAR, 0.00001);
                     ")
  end

  def test_negative_float
    @runtime.execute("
                     var MYVAR=-0.2345;
                     assert_equal(-0.2345, MYVAR++);
                     assert_in_delta(0.7655, MYVAR, 0.00001);
                     ")
  end

  @@tests.each do |testing|
    testing.each do |name, values|
      define_method(:"test_#{name}") do
        @runtime.execute("
                         var MYVAR=#{values[0]};
                         assert_equal(#{values[1]}, MYVAR++);
                         assert_equal(#{values[2]}, MYVAR);
                         ")
      end
    end
  end
end
