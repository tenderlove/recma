require File.dirname(__FILE__) + "/helper"

class LineNumberTest < NodeTestCase
  def test_line_numbers
    p = RKelly::Parser.new
    ast = p.parse(<<-eojs)
      function aaron() {
        var x = 10;
        return 1 + 1;
      }
    eojs
    func = ast.pointcut(FunctionDeclNode).matches.first
    assert func
    assert_equal(1, func.line)

    return_node = ast.pointcut(ReturnNode).matches.first
    assert return_node
    assert_equal(3, return_node.line)
  end
end
