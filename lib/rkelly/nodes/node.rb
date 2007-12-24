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

      def to_dots
        visitor = DotVisitor.new
        visitor.accept(self)
        header = <<-END
digraph g {
graph [ rankdir = "TB" ];
node [
  fontsize = "16"
  shape = "ellipse"
];
edge [ ];
        END
        nodes = visitor.nodes.map { |x| x.to_s }.join("\n")
        counter = 0
        arrows = visitor.arrows.map { |x|
          s = "#{x} [\nid = #{counter}\n];"
          counter += 1
          s
        }.join("\n")
        "#{header}\n#{nodes}\n#{arrows}\n}"
      end
    end
  end
end
