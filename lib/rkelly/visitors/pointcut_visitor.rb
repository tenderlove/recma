module RKelly
  module Visitors
    class PointcutVisitor < Visitor
      attr_reader :matches
      def initialize(ast)
        @ast      = ast
        @matches  = []
      end

      ALL_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          @matches << o if @ast =~ o
          super
        end
      end
    end
  end
end
