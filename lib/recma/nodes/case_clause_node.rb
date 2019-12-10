require 'recma/nodes/binary_node'

module RECMA
  module Nodes
    class CaseClauseNode < BinaryNode
      def initialize(left, src = SourceElementsNode.new([]))
        super
      end
    end
  end
end
