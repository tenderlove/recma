require File.dirname(__FILE__) + "/helper"

class CommentsTest < NodeTestCase
  def test_some_comments
    parser = RKelly::Parser.new
    ast = parser.parse(<<-eojs)
      /**
       * This is an awesome test comment.
       */
      function aaron() { // This is a side comment
        var x = 10;
        return 1 + 1; // America!
      }
    eojs

    func = ast.pointcut(FunctionDeclNode).matches.first
    assert func
    assert_match('awesome', func.comments[0].value)
    assert_match('side', func.comments[1].value)

    return_node = ast.pointcut(ReturnNode).matches.first
    assert return_node
    assert_match('America', return_node.comments[0].value)
  end

  def test_even_more_comments
    parser = RKelly::Parser.new
    ast = parser.parse(<<-eojs)
      /**
       * The first comment
       */
      /**
       * This is an awesome test comment.
       */
      function aaron() { // This is a side comment
        var x = 10;
        return 1 + 1; // America!
      }
    eojs
    func = ast.pointcut(FunctionDeclNode).matches.first
    assert func
    assert_equal(3, func.comments.length)
  end
end
