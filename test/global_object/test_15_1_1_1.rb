require File.dirname(__FILE__) + "/../helper"

class GlobalObject_15_1_1_1_Test < Test::Unit::TestCase
  include RKelly::JS

  def setup
    @object = GlobalObject.new
  end

  def test_nan
    assert @object.has_property?('NaN')
    assert @object['NaN'].dont_enum?
    assert @object['NaN'].dont_delete?
    assert @object['NaN'].value.nan?
  end
end
