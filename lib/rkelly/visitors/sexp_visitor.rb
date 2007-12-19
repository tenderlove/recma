module RKelly
  module Visitors
    class SexpVisitor < Visitor
      def visit_Node(o)
        [:lit, o.value]
      end

      def visit_NullNode(o)
        [:nil]
      end
      
      def visit_StringNode(o)
        [:str, o.value]
      end

      def visit_FalseNode(o)
        [:false]
      end

      def visit_TrueNode(o)
        [:true]
      end
    end
  end
end
