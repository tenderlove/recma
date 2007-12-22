%w{
  node
  null_node
  true_node
  false_node
  number_node
  string_node
  regexp_node
  assign_expr_node
  var_decl_node
  var_statement_node
  const_statement_node
  empty_statement_node
  source_elements
  resolve_node
}.each do |node|
  require "rkelly/nodes/#{node}"
end
require 'rkelly/nodes/bracket_accessor_node'
require 'rkelly/nodes/dot_accessor_node'
require 'rkelly/nodes/arguments_node'
require 'rkelly/nodes/new_expr_node'
require 'rkelly/nodes/function_body_node'
require 'rkelly/nodes/function_expr_node'
require 'rkelly/nodes/parameter_node'
require 'rkelly/nodes/function_decl_node'
require 'rkelly/nodes/return_node'
require 'rkelly/nodes/break_node'
require 'rkelly/nodes/continue_node'
require 'rkelly/nodes/label_node'
require 'rkelly/nodes/throw_node'
require 'rkelly/nodes/property_node'
require 'rkelly/nodes/object_literal_node'
require 'rkelly/nodes/getter_property_node'
require 'rkelly/nodes/setter_property_node'
require 'rkelly/nodes/this_node'
require 'rkelly/nodes/element_node'
require 'rkelly/nodes/array_node'
require 'rkelly/nodes/expression_statement_node'
require 'rkelly/nodes/op_equal_node'
require 'rkelly/nodes/comma_node'
require 'rkelly/nodes/op_plus_equal_node'
require 'rkelly/nodes/op_minus_equal_node'
require 'rkelly/nodes/op_multiply_equal_node'
require 'rkelly/nodes/op_divide_equal_node'
require 'rkelly/nodes/op_l_shift_equal_node'
require 'rkelly/nodes/op_r_shift_equal_node'
require 'rkelly/nodes/op_u_r_shift_equal_node'
require 'rkelly/nodes/op_and_equal_node'
require 'rkelly/nodes/op_x_or_equal_node'
require 'rkelly/nodes/op_or_equal_node'
require 'rkelly/nodes/op_mod_equal_node'
require 'rkelly/nodes/function_call_node'
require 'rkelly/nodes/postfix_node'
require 'rkelly/nodes/delete_node'
require 'rkelly/nodes/void_node'
require 'rkelly/nodes/type_of_node'
require 'rkelly/nodes/prefix_node'
require 'rkelly/nodes/unary_plus_node'
require 'rkelly/nodes/unary_minus_node'
require 'rkelly/nodes/bitwise_not_node'
require 'rkelly/nodes/logical_not_node'
