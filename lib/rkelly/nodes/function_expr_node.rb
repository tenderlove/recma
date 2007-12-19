module RKelly
  module Nodes
    class FunctionExprNode < Node
      attr_reader :function_body
      def initialize(name, body)
        super(name)
        @function_body = body
      end
    end
  end
end
