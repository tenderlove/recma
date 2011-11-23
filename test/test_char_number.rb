require File.dirname(__FILE__) + "/helper"

class CharNumberTest < NodeTestCase
  def test_line_numbers
    parser = RKelly::Parser.new
    ast = parser.parse(<<-eojs)
      /**
       * This is an awesome test comment.
       */
      function aaron() {
        var x = 10;
        return 1 + 1;
      }
    eojs
    func = ast.pointcut(FunctionDeclNode).matches.first
    assert func
    assert_equal(7, func.character)

    return_node = ast.pointcut(ReturnNode).matches.first
    assert return_node
    assert_equal(9, return_node.character)
  end
end
