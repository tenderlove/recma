module RKelly
  module Visitors
    class SexpVisitor < Visitor
      def visit_NumberNode(o)
        [:lit, o.value]
      end
    end
  end
end
