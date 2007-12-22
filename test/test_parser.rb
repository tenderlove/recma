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
            [:assign, [:bracket_access, [:resolve, "foo"], [:lit, 10]]],
          ]]
        ]
      ],
      @parser.parse('var a = foo[10];'))
  end

  def test_function_expr_anon_no_args
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:func_expr, nil, [], [:func_body, []]]
                  ]]]
                ]],
                @parser.parse("var foo = function() { }"))
  end

  def test_function_body_expr_anon_no_args
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:func_expr, nil, [],
                      [:func_body,
                        [:var, [[:var_decl, :a, [:assign, [:lit, 10]]]]]
                      ]
                    ]
                  ]]]
                ]],
                @parser.parse("var foo = function() { var a = 10; }"))
  end

  def test_function_expr_anon_single_arg
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:func_expr, nil, [[:param, "a"]], [:func_body, []]]
                  ]]]
                ]],
                @parser.parse("var foo = function(a) { }"))
  end

  def test_function_expr_anon
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:func_expr, nil, [[:param, "a"], [:param, 'b']], [:func_body, []]]
                  ]]]
                ]],
                @parser.parse("var foo = function(a,b) { }"))
  end

  def test_function_expr_no_args
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:func_expr, 'aaron', [], [:func_body, []]]
                  ]]]
                ]],
                @parser.parse("var foo = function aaron() { }"))
  end

  def test_function_expr_with_args
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:func_expr, 'aaron', [[:param, 'a'], [:param, 'b']], [:func_body, []]]
                  ]]]
                ]],
                @parser.parse("var foo = function aaron(a, b) { }"))
  end

  def test_labelled_statement
    assert_sexp([[:label, "foo", [:var, [[:var_decl, :x, [:assign, [:lit, 10]]]]]]],
                @parser.parse('foo: var x = 10;'))
    assert_sexp([[:label, "foo", [:var, [[:var_decl, :x, [:assign, [:lit, 10]]]]]]],
                @parser.parse('foo: var x = 10'))
  end

  def test_throw_statement
    assert_sexp([[:throw, [:lit, 10]]], @parser.parse('throw 10;'))
    assert_sexp([[:throw, [:lit, 10]]], @parser.parse('throw 10'))
  end

  def test_object_literal
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:object, [[:property, "bar", [:lit, 10]]]]
                  ]]]
                ]],
                @parser.parse('var foo = { bar: 10 }'))
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:object, []]
                  ]]]
                ]],
                @parser.parse('var foo = { }'))
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:object, [[:property, '"bar"', [:lit, 10]]]]
                  ]]]
                ]],
                @parser.parse('var foo = { "bar": 10 }'))
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:object, [[:property, 5, [:lit, 10]]]]
                  ]]]
                ]],
                @parser.parse('var foo = { 5: 10 }'))
  end

  def test_object_literal_getter
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:object, [[:getter, 'a', [:func_expr, nil, [], [:func_body, []]]]]]
                  ]]]
                ]],
                @parser.parse('var foo = { get a() { } }'))
  end

  def test_object_literal_setter
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:object, [[:setter, 'a',
                      [:func_expr, nil, [[:param, 'foo']], [:func_body, []]]
                    ]]]
                  ]]]
                ]],
                @parser.parse('var foo = { set a(foo) { } }'))
  end

  def test_object_literal_multi
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:object, [
                      [:property, "bar", [:lit, 10]],
                      [:property, "baz", [:lit, 1]]
                    ]]
                  ]]]
                ]],
                @parser.parse('var foo = { bar: 10, baz: 1 }'))
    assert_sexp(
                [[:var,
                  [[:var_decl, :foo, [:assign,
                    [:object, [
                      [:property, "bar", [:lit, 10]],
                      [:property, "baz", [:lit, 1]]
                    ]]
                  ]]]
                ]],
                @parser.parse('var foo = { bar: 10, baz: 1, }'))
  end

  def test_this
    assert_sexp(
                [[:var, [[:var_decl, :foo, [:assign, [:this]]]]]],
                @parser.parse('var foo = this;')
               )
  end

  def test_array_literal
    assert_sexp(
                [[:var, [[:var_decl, :foo, [:assign,
                  [:array, [[:element, [:lit, 1]]]]
                ]]]]],
                @parser.parse('var foo = [1];')
               )
    assert_sexp(
                [[:var, [[:var_decl, :foo, [:assign,
                  [:array, [
                    nil,
                    nil,
                    [:element, [:lit, 1]]
                  ]]
                ]]]]],
                @parser.parse('var foo = [,,1];')
               )
    assert_sexp(
                [[:var, [[:var_decl, :foo, [:assign,
                  [:array, [
                    [:element, [:lit, 1]],
                    nil,
                    nil,
                    [:element, [:lit, 2]]
                  ]]
                ]]]]],
                @parser.parse('var foo = [1,,,2];')
               )
    assert_sexp(
                [[:var, [[:var_decl, :foo, [:assign,
                  [:array, [
                    [:element, [:lit, 1]],
                    nil,
                    nil,
                  ]]
                ]]]]],
                @parser.parse('var foo = [1,,,];')
               )
    assert_sexp(
                [[:var, [[:var_decl, :foo, [:assign,
                  [:array, [
                  ]]
                ]]]]],
                @parser.parse('var foo = [];')
               )
    assert_sexp(
                [[:var, [[:var_decl, :foo, [:assign,
                  [:array, [
                    nil, nil
                  ]]
                ]]]]],
                @parser.parse('var foo = [,,];')
               )
  end

  def test_primary_expr_paren
    assert_sexp(
      [[:var,
        [[:var_decl, :a, [:assign, [:lit, 10]]]]
      ]],
      @parser.parse('var a = (10);'))
  end

  def test_expression_statement
    assert_sexp(
                [[:expression, [:dot_access, [:resolve, "foo"], "bar"]]],
                @parser.parse('foo.bar;')
               )
    assert_sexp(
                [[:expression, [:dot_access, [:resolve, "foo"], "bar"]]],
                @parser.parse('foo.bar')
               )
  end

  def test_expr_comma
    assert_sexp([[:expression, [:comma,
                [:op_equal, [:resolve, 'i'], [:lit, 10]],
                [:op_equal, [:resolve, 'j'], [:lit, 11]]]]],
                @parser.parse('i = 10, j = 11;')
               )
  end

  def test_op_plus_equal
    assert_sexp([[:expression, [:op_plus_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i += 10'))
  end

  def test_op_minus_equal
    assert_sexp([[:expression, [:op_minus_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i -= 10'))
  end

  def test_op_multiply_equal
    assert_sexp([[:expression, [:op_multiply_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i *= 10'))
  end

  def test_op_divide_equal
    assert_sexp([[:expression, [:op_divide_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i /= 10'))
  end

  def test_op_lshift_equal
    assert_sexp([[:expression, [:op_lshift_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i <<= 10'))
  end

  def test_op_rshift_equal
    assert_sexp([[:expression, [:op_rshift_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i >>= 10'))
  end

  def test_op_urshift_equal
    assert_sexp([[:expression, [:op_urshift_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i >>>= 10'))
  end

  def test_op_and_equal
    assert_sexp([[:expression, [:op_and_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i &= 10'))
  end

  def test_op_xor_equal
    assert_sexp([[:expression, [:op_xor_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i ^= 10'))
  end

  def test_op_or_equal
    assert_sexp([[:expression, [:op_or_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i |= 10'))
  end

  def test_op_mod_equal
    assert_sexp([[:expression, [:op_mod_equal, [:resolve, 'i'], [:lit, 10]]]],
                @parser.parse('i %= 10'))
  end

  def test_bracket_access_no_bf
    assert_sexp(
      [[:expression,
            [:bracket_access, [:resolve, "foo"], [:lit, 10]],
      ]],
      @parser.parse('foo[10];'))
  end

  def test_new_member_expr_no_bf
    assert_sexp(
      [[:expression,
            [:new_expr, [:resolve, "foo"], [:args, []]],
      ]],
      @parser.parse('new foo();'))
  end

  def test_resolve_function_call
    assert_sexp([[:var,
                  [[:var_decl,
                    :x,
                    [:assign, [:function_call, [:resolve, "bar"], [:args, []]]]
                  ]]
                ]],
                @parser.parse('var x = bar();'))
    assert_sexp([[:var,
                  [[:var_decl,
                    :x,
                    [:assign, [:function_call, [:resolve, "bar"], [:args, [[:lit, 10]]]]]
                  ]]
                ]],
                @parser.parse('var x = bar(10);'))
    assert_sexp([[:var,
                  [[:var_decl,
                    :x,
                    [:assign, [:function_call, [:resolve, "bar"], [:args, [
                      [:resolve, 'a'],
                      [:lit, 10]
                    ]]]]
                  ]]
                ]],
                @parser.parse('var x = bar(a,10);'))
  end

  def test_function_no_bf
    assert_sexp([[:expression,
                  [:function_call, [:resolve, "bar"], [:args, []]]
                ]],
                @parser.parse('bar();'))
  end

  def test_function_on_function_no_bf
    assert_sexp([[:expression,
                  [:function_call,
                    [:function_call, [:resolve, "bar"], [:args, []]],
                    [:args, []]
                  ]
                ]],
                @parser.parse('bar()();'))
  end

  def test_bracket_on_function_no_bf
    assert_sexp([[:expression,
                  [:bracket_access,
                    [:function_call, [:resolve, "bar"], [:args, []]],
                    [:lit, 1],
                  ]
                ]],
                @parser.parse('bar()[1];'))
  end

  def test_dot_on_function_no_bf
    assert_sexp([[:expression,
                  [:dot_access,
                    [:function_call, [:resolve, "bar"], [:args, []]],
                    'baz',
                  ]
                ]],
                @parser.parse('bar().baz;'))
  end

  def test_new_expr_no_bf
    assert_sexp([[:expression, [:new_expr, [:resolve, 'foo'], [:args, []]]]],
      @parser.parse('new foo;'))
  end

  def test_new_expr
    assert_sexp([[:var, [[:var_decl, :a, [:assign, [:new_expr, [:resolve, 'foo'], [:args, []]]]]]]],
      @parser.parse('var a = new foo;'))
  end

  def test_postfix_expr
    assert_sexp([[:var,
                [[:var_decl,
                  :x,
                  [:assign, [:postfix, [:lit, 10], '++']]]]]],
                  @parser.parse('var x = 10++;'))
    assert_sexp([[:var,
                [[:var_decl,
                  :x,
                  [:assign, [:postfix, [:lit, 10], '--']]]]]],
                  @parser.parse('var x = 10--;'))
  end

  def test_postfix_expr_no_bf
    assert_sexp([[:expression,
                  [:postfix, [:lit, 10], '++']]],
                  @parser.parse('10++;'))
    assert_sexp([[:expression,
                  [:postfix, [:lit, 10], '--']]],
                  @parser.parse('10--;'))
  end

  def test_unary_delete
    assert_sexp([[:expression, [:delete, [:resolve, 'foo']]]],
                @parser.parse('delete foo;'))
  end

  def test_unary_void
    assert_sexp([[:expression, [:void, [:resolve, 'foo']]]],
                @parser.parse('void foo;'))
  end

  def test_unary_typeof
    assert_sexp([[:expression, [:typeof, [:resolve, 'foo']]]],
                @parser.parse('typeof foo;'))
  end

  def test_unary_prefix
    assert_sexp([[:expression, [:prefix, [:lit, 10], '++']]],
                @parser.parse('++10;'))
    assert_sexp([[:expression, [:prefix, [:lit, 10], '--']]],
                @parser.parse('--10;'))
  end

  def test_unary_plus
    assert_sexp([[:expression, [:u_plus, [:lit, 10]]]],
                @parser.parse('+10;'))
  end

  def test_unary_minus
    assert_sexp([[:expression, [:u_minus, [:lit, 10]]]],
                @parser.parse('-10;'))
  end

  def test_unary_bitwise_not
    assert_sexp([[:expression, [:bitwise_not, [:lit, 10]]]],
                @parser.parse('~10;'))
  end

  def test_unary_logical_not
    assert_sexp([[:expression, [:logical_not, [:lit, 10]]]],
                @parser.parse('!10;'))
  end

  def test_function_call_on_function
    assert_sexp([[:var,
                  [[:var_decl,
                    :x,
                    [:assign, [:function_call, 
                      [:function_call, [:resolve, "bar"], [:args, []]],
                    [:args, []]]]
                  ]]
                ]],
                @parser.parse('var x = bar()();'))
  end

  def test_bracket_on_function
    assert_sexp([[:var,
                  [[:var_decl,
                    :x,
                    [:assign, [:bracket_access,
                      [:function_call, [:resolve, "bar"], [:args, []]],
                      [:lit, 1]
                    ]]
                  ]]
                ]],
                @parser.parse('var x = bar()[1];'))
  end

  def test_dot_on_function
    assert_sexp([[:var,
                  [[:var_decl,
                    :x,
                    [:assign, [:dot_access,
                      [:function_call, [:resolve, "bar"], [:args, []]],
                      'baz'
                    ]]
                  ]]
                ]],
                @parser.parse('var x = bar().baz;'))
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
        [:const, [[:const_decl, :foo, [:assign, [:lit, 10]]]]],
        [:empty]
      ],
      @parser.parse('const foo = 10; ;')
    )
  end

  def test_debugger_statement
    assert_sexp(
      [ [:empty] ],
      @parser.parse('debugger;')
    )
    assert_sexp(
      [ [:empty] ],
      @parser.parse('debugger')
    )
  end

  def test_function_decl
    assert_sexp([[:func_decl, 'foo', [], [:func_body, []]]],
                @parser.parse('function foo() { }'))
  end

  def test_function_decl_params
    assert_sexp([[:func_decl, 'foo', [[:param, 'a']], [:func_body, []]]],
                @parser.parse('function foo(a) { }'))
  end

  def test_const_statement
    assert_sexp(
      [[:const, [[:const_decl, :foo, [:assign, [:lit, 10]]]]]],
      @parser.parse('const foo = 10;')
    )
  end

  def test_const_decl_list
    assert_sexp(
      [[:const,
        [
          [:const_decl, :foo, [:assign, [:lit, 10]]],
          [:const_decl, :bar, [:assign, [:lit, 1]]],
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
      [[:const, [[:const_decl, :foo, [:assign, [:lit, 10]]]]]],
      @parser.parse('const foo = 10')
    )
  end

  def test_variable_statement
    assert_sexp(
      [[:var, [[:var_decl, :foo, [:assign, [:lit, 10]]]]]],
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
      [[:var, [[:var_decl, :foo, [:assign, [:lit, 10]]]]]],
      @parser.parse('var foo = 10')
    )
  end

  def test_return_statement
    assert_sexp(
      [[:return]],
      @parser.parse('return;')
    )
    assert_sexp(
      [[:return]],
      @parser.parse('return')
    )
    assert_sexp(
      [[:return, [:lit, 10]]],
      @parser.parse('return 10;')
    )
    assert_sexp(
      [[:return, [:lit, 10]]],
      @parser.parse('return 10')
    )
  end

  def test_break_statement
    assert_sexp([[:break]], @parser.parse('break;'))
    assert_sexp([[:break]], @parser.parse('break'))
    assert_sexp([[:break, 'foo']], @parser.parse('break foo;'))
    assert_sexp([[:break, 'foo']], @parser.parse('break foo'))
  end

  def test_continue_statement
    assert_sexp([[:continue]], @parser.parse('continue;'))
    assert_sexp([[:continue]], @parser.parse('continue'))
    assert_sexp([[:continue, 'foo']], @parser.parse('continue foo;'))
    assert_sexp([[:continue, 'foo']], @parser.parse('continue foo'))
  end

  def test_variable_declaration_list
    assert_sexp(
      [[:var,
        [
          [:var_decl, :foo, [:assign, [:lit, 10]]],
          [:var_decl, :bar, [:assign, [:lit, 1]]],
      ]]],
      @parser.parse('var foo = 10, bar = 1;')
    )
  end

  def assert_sexp(expected, node)
    assert_equal(expected, node.to_sexp)
  end
end
