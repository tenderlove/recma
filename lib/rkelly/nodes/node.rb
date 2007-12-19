module RKelly
  module Nodes
    class Node
      include RKelly::Visitable
      include RKelly::Visitors

      attr_reader :value
      def initialize(value)
        @value = value
      end

      def to_sexp
        SexpVisitor.new.accept(self)
      end
    end
  end
end
