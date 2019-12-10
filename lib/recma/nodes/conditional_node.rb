require 'recma/nodes/if_node'

module RECMA
  module Nodes
    class ConditionalNode < IfNode
      def initialize(test, true_block, else_block)
        super
      end
    end
  end
end
