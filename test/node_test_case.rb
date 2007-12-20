require File.dirname(__FILE__) + "/helper"

class NodeTestCase < Test::Unit::TestCase
  include RKelly::Nodes

  undef :default_test

  def assert_sexp(expected, actual)
    assert_equal(expected, actual.to_sexp)
  end
end
