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
                @parser.parse('var a = foo[10];').to_sexp)
  end

  def test_empty_statement
    assert_sexp(
      [
        [:const, [[:const_decl, :foo, [:assign, [:lit, "10"]]]]],
        [:empty]
      ],
      @parser.parse('const foo = 10; ;').to_sexp
    )
  end

  def test_const_statement
    assert_sexp(
      [[:const, [[:const_decl, :foo, [:assign, [:lit, "10"]]]]]],
      @parser.parse('const foo = 10;').to_sexp
    )
  end

  def test_const_decl_list
    assert_sexp(
      [[:const,
        [
          [:const_decl, :foo, [:assign, [:lit, "10"]]],
          [:const_decl, :bar, [:assign, [:lit, "1"]]],
      ]]],
      @parser.parse('const foo = 10, bar = 1;').to_sexp
    )
  end

  def test_const_decl_no_init
    assert_sexp(
      [[:const, [[:const_decl, :foo, nil]]]],
      @parser.parse('const foo;').to_sexp
    )
  end

  def test_const_statement_error
    assert_sexp(
      [[:const, [[:const_decl, :foo, [:assign, [:lit, "10"]]]]]],
      @parser.parse('const foo = 10').to_sexp
    )
  end

  def test_variable_statement
    assert_sexp(
      [[:var, [[:var_decl, :foo, [:assign, [:lit, "10"]]]]]],
      @parser.parse('var foo = 10;').to_sexp
    )
  end

  def test_variable_declaration_no_init
    assert_sexp(
      [[:var, [[:var_decl, :foo, nil]]]],
      @parser.parse('var foo;').to_sexp
    )
  end

  def test_variable_declaration_nil_init
    assert_sexp(
      [[:var, [[:var_decl, :foo, [:assign, [:nil]]]]]],
      @parser.parse('var foo = null;').to_sexp
    )
  end

  def test_variable_statement_no_semi
    assert_sexp(
      [[:var, [[:var_decl, :foo, [:assign, [:lit, "10"]]]]]],
      @parser.parse('var foo = 10').to_sexp
    )
  end

  def test_variable_declaration_list
    assert_sexp(
      [[:var,
        [
          [:var_decl, :foo, [:assign, [:lit, "10"]]],
          [:var_decl, :bar, [:assign, [:lit, "1"]]],
      ]]],
      @parser.parse('var foo = 10, bar = 1;').to_sexp
    )
  end

  def assert_sexp(expected, actual)
    assert_equal(expected, actual)
  end
end
