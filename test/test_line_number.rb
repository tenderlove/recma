require File.dirname(__FILE__) + "/helper"

class LineNumberTest < NodeTestCase
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
    assert_equal(4, func.line)

    return_node = ast.pointcut(ReturnNode).matches.first
    assert return_node
    assert_equal(6, return_node.line)
  end

  def test_ranges
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
    assert_equal([[4, 7], [7, 7]], func.range)

    return_node = ast.pointcut(ReturnNode).matches.first
    assert return_node
    assert_equal([[6, 9], [6, 21]], return_node.range)
  end
end
