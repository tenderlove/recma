module RKelly
  module Nodes
    class PropertyNode < Node
      attr_reader :name
      def initialize(name, value)
        super(value)
        @name = name
      end
    end
  end
end
