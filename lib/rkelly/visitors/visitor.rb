module RKelly
  module Visitors
    class Visitor
      def accept(target)
        target.accept(self)
      end
    end
  end
end
