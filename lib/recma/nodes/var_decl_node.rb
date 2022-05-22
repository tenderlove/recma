module RECMA
  module Nodes
    class VarDeclNode < Node
      attr_accessor :name, :type
      # constant can be true (for const), false (for var), or :let (for let).
      def initialize(name, value, constant = false)
        super(value)
        @name = name
        @constant = constant
      end

      def const?; @constant == true;  end
      def let?;   @constant == :let;  end
      def var?;   @constant == false; end

      alias constant? const?
      alias variable? var?
    end
  end
end
