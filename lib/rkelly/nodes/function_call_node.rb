module RKelly
  module Nodes
    class FunctionCallNode < Node
      attr_reader :arguments
      def initialize(value, arguments)
        super(value)
        @arguments = arguments
      end
    end
  end
end
