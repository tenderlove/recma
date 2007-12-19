require File.dirname(__FILE__) + "/helper"

class ParserTest < Test::Unit::TestCase
  def setup
    @parser = RKelly::Parser.new
  end

  def test_variable_statement
    #require 'pp'
    #pp @parser.parse('var foo = 10;')
  end
end
