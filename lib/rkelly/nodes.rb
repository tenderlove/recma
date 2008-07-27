require 'rkelly/nodes/node'
require 'rkelly/nodes/function_expr_node'
Dir[File.join(File.dirname(__FILE__), "nodes/*_node.rb")].each do |file|
  require file[/rkelly\/nodes\/.*/]
end
