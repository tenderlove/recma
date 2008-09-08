module RKelly
  module Visitors
    class PointcutVisitor < Visitor
      attr_reader :matches
      def initialize(pattern)
        @pattern  = pattern
        @matches  = []
      end

      ALL_NODES.each do |type|
        define_method(:"visit_#{type}Node") do |o|
          @matches << o if @pattern === o
          super
        end
      end
    end
  end
end
