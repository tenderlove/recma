$LOAD_PATH.unshift File.join('..', 'lib')

require 'test/unit'
require 'rkelly'

class TestJSArray < Test::Unit::TestCase
  def setup
    @obj = RKelly::JSArray.new
  end

  def test_string_index
    @obj['something'] = 'aaron'
    assert @obj.respond_to?(:something)
    assert_equal('aaron', @obj.something)
    assert_equal('aaron', @obj['something'])

    class << @obj
      alias :old_something :something
      def something
        'patterson'
      end
    end

    assert_equal('patterson', @obj.something)
    assert_equal('patterson', @obj['something'])

    @obj['something'] = 'aaron'
    assert_equal('aaron', @obj.something)
    assert_equal('aaron', @obj['something'])

    @obj[1.2] = 'aaron'
    assert_equal('aaron', @obj[1.2])
  end

  def test_int_index
    assert_equal(0, @obj.length)
    @obj[0] = 'aaron'
    assert_equal(1, @obj.length)
    @obj['asdfasdf'] = 'aaron'
    assert_equal(1, @obj.length)
  end
end

