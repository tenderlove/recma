require File.dirname(__FILE__) + "/helper"

class ParserTest < Test::Unit::TestCase
  def setup
    @parser = RKelly::Parser.new
  end

  def test_array_access
    assert_sexp(
      [
        [:var,
          [[:var_decl, :a,
            [:assign, [:bracket_access, [:resolve, "foo"], [:lit, "10"]]],
          ]]
        ]
      ],
      @parser.parse('var a = foo[10];'))
  end

  def test_function_expr_anon_no_args
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:func_expr, nil, [:func_body, []]]
                  ]]]
                ]],
                @parser.parse("var foo = function() { }"))
  end

  def test_dot_access
    assert_sexp(
      [[:var,
        [[:var_decl, :a, [:assign, [:dot_access, [:resolve, "foo"], "bar"]]]]
      ]],
      @parser.parse('var a = foo.bar;'))
  end

  def test_new_member_expr
    assert_sexp(
      [[:var,
        [[:var_decl, :a,
          [:assign, [:new_expr, [:resolve, "foo"], [:args, []]]]
        ]]
      ]],
      @parser.parse('var a = new foo();'))
  end

  def test_empty_statement
    assert_sexp(
      [
        [:const, [[:const_decl, :foo, [:assign, [:lit, "10"]]]]],
        [:empty]
      ],
      @parser.parse('const foo = 10; ;')
    )
  end

  def test_const_statement
    assert_sexp(
      [[:const, [[:const_decl, :foo, [:assign, [:lit, "10"]]]]]],
      @parser.parse('const foo = 10;')
    )
  end

  def test_const_decl_list
    assert_sexp(
      [[:const,
        [
          [:const_decl, :foo, [:assign, [:lit, "10"]]],
          [:const_decl, :bar, [:assign, [:lit, "1"]]],
      ]]],
      @parser.parse('const foo = 10, bar = 1;')
    )
  end

  def test_const_decl_no_init
    assert_sexp(
      [[:const, [[:const_decl, :foo, nil]]]],
      @parser.parse('const foo;')
    )
  end

  def test_const_statement_error
    assert_sexp(
      [[:const, [[:const_decl, :foo, [:assign, [:lit, "10"]]]]]],
      @parser.parse('const foo = 10')
    )
  end

  def test_variable_statement
    assert_sexp(
      [[:var, [[:var_decl, :foo, [:assign, [:lit, "10"]]]]]],
      @parser.parse('var foo = 10;')
    )
  end

  def test_variable_declaration_no_init
    assert_sexp(
      [[:var, [[:var_decl, :foo, nil]]]],
      @parser.parse('var foo;')
    )
  end

  def test_variable_declaration_nil_init
    assert_sexp(
      [[:var, [[:var_decl, :foo, [:assign, [:nil]]]]]],
      @parser.parse('var foo = null;')
    )
  end

  def test_variable_statement_no_semi
    assert_sexp(
      [[:var, [[:var_decl, :foo, [:assign, [:lit, "10"]]]]]],
      @parser.parse('var foo = 10')
    )
  end

  def test_variable_declaration_list
    assert_sexp(
      [[:var,
        [
          [:var_decl, :foo, [:assign, [:lit, "10"]]],
          [:var_decl, :bar, [:assign, [:lit, "1"]]],
      ]]],
      @parser.parse('var foo = 10, bar = 1;')
    )
  end

  def assert_sexp(expected, node)
    assert_equal(expected, node.to_sexp)
  end
end
