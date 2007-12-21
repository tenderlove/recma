module RKelly
  module Nodes
    class OpEqualNode < Node
      attr_reader :left
      def initialize(left, right)
        super(right)
        @left = left
      end
    end
  end
end
