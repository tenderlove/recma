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
