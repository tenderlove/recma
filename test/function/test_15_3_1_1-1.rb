require File.dirname(__FILE__) + "/../helper"

class Expressions_15_3_1_1_1_Test < ECMAScriptTestCase
  def setup
    super
    @runtime.execute(<<END
var MyObject = Function( "value", "this.value = value; this.valueOf =  Funct
ion( 'return this.value' ); this.toString =  Function( 'return String(this.value
);' )" );
var myfunc = Function();
myfunc.toString = Object.prototype.toString;
END
                    )
  end

  def test_to_string
    js_assert_equal("'[object Function]'", "myfunc.toString()")
  end

  #def test_prototype_to_string
  #  js_assert_equal("'[object Object]'", "myfunc.prototype.toString()")
  #end
end
