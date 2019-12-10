require File.dirname(__FILE__) + "/helper"

class RECMATest < Test::Unit::TestCase
  def test_array_access
    assert_sexp(
      [
        [:var,
          [[:var_decl, :a,
            [:assign, [:bracket_access, [:resolve, "foo"], [:lit, 10]]],
          ]]
        ]
      ],
      RECMA.parse('var a = foo[10];'))
  end

  def assert_sexp(expected, node)
    assert_equal(expected, node.to_sexp)
  end
end
