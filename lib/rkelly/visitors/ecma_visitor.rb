module RKelly
  module Visitors
    class ECMAVisitor < Visitor
      def initialize
        @indent = 0
      end

      def visit_SourceElements(o)
        o.value.map { |x| x.accept(self) }.join("\n")
      end

      def visit_VarStatementNode(o)
        "#{indent}var #{o.value.map { |x| x.accept(self) }.join(', ')};"
      end

      def visit_VarDeclNode(o)
        "#{o.name}#{o.value ? o.value.accept(self) : nil}"
      end

      def visit_AssignExprNode(o)
        " = #{o.value.accept(self)}"
      end

      def visit_NumberNode(o)
        o.value.to_s
      end

      def visit_ForNode(o)
        init    = o.init ? o.init.accept(self) : ';'
        test    = o.test ? o.test.accept(self) : ''
        counter = o.counter ? o.counter.accept(self) : ''
        "#{indent}for(#{init} #{test}; #{counter}) #{o.value.accept(self)}"
      end

      def visit_LessNode(o)
        "#{o.left.accept(self)} < #{o.value.accept(self)}"
      end

      def visit_ResolveNode(o)
        o.value
      end

      def visit_PostfixNode(o)
        "#{o.operand.accept(self)}#{o.value}"
      end

      def visit_PrefixNode(o)
        "#{o.value}#{o.operand.accept(self)}"
      end

      def visit_BlockNode(o)
        @indent += 1
        "{\n#{o.value.accept(self)}\n#{@indent -=1; indent}}"
      end

      def visit_ExpressionStatementNode(o)
        "#{indent}#{o.value.accept(self)};"
      end

      def visit_OpEqualNode(o)
        "#{o.left.accept(self)} = #{o.value.accept(self)}"
      end

      def visit_FunctionCallNode(o)
        "#{o.value.accept(self)}(#{o.arguments.accept(self)})"
      end

      def visit_ArgumentsNode(o)
        o.value.map { |x| x.accept(self) }.join(', ')
      end

      def visit_StringNode(o)
        o.value
      end

      def visit_NullNode(o)
        "null"
      end

      def visit_FunctionDeclNode(o)
        "#{indent}function #{o.value}(" +
          "#{o.arguments.map { |x| x.accept(self) }.join(', ')})" +
          "#{o.function_body.accept(self)}"
      end

      def visit_ParameterNode(o)
        o.value
      end

      def visit_FunctionBodyNode(o)
        @indent += 1
        "{\n#{o.value.accept(self)}\n#{@indent -=1; indent}}"
      end

      def visit_BreakNode(o)
        "#{indent}break" + (o.value ? " #{o.value}" : '') + ';'
      end

      def visit_ContinueNode(o)
        "#{indent}continue" + (o.value ? " #{o.value}" : '') + ';'
      end

      def visit_TrueNode(o)
        "true"
      end

      def visit_FalseNode(o)
        "false"
      end

      def visit_EmptyStatementNode(o)
        ';'
      end

      def visit_RegexpNode(o)
        o.value
      end

      def visit_DotAccessorNode(o)
        "#{o.value.accept(self)}.#{o.accessor}"
      end

      def visit_ThisNode(o)
        "this"
      end

      # Single value nodes
      %w{
        BitwiseNotNode DeleteNode ElementNode
        LogicalNotNode ReturnNode
        ThrowNode TypeOfNode UnaryMinusNode UnaryPlusNode VoidNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise
        end
      end
      # End Single value nodes

      # Binary nodes
      %w{
        AddNode BitAndNode BitOrNode BitXOrNode CaseClauseNode CommaNode
        DivideNode DoWhileNode EqualNode GreaterNode GreaterOrEqualNode InNode
        InstanceOfNode LeftShiftNode LessOrEqualNode LogicalAndNode
        LogicalOrNode ModulusNode MultiplyNode NotEqualNode NotStrictEqualNode
        OpAndEqualNode OpDivideEqualNode OpLShiftEqualNode
        OpMinusEqualNode OpModEqualNode OpMultiplyEqualNode OpOrEqualNode
        OpPlusEqualNode OpRShiftEqualNode OpURShiftEqualNode OpXOrEqualNode
        RightShiftNode StrictEqualNode SubtractNode SwitchNode
        UnsignedRightShiftNode WhileNode WithNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise
        end
      end
      # End Binary nodes

      # Array Value Nodes
      %w{
        ArrayNode CaseBlockNode ConstStatementNode
        ObjectLiteralNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise
        end
      end
      # END Array Value Nodes

      # Name and Value Nodes
      %w{
        LabelNode PropertyNode GetterPropertyNode SetterPropertyNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise
        end
      end
      # END Name and Value Nodes

      %w{ IfNode ConditionalNode }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise
        end
      end

      def visit_ForInNode(o)
        raise
      end

      def visit_TryNode(o)
        raise
      end

      def visit_BracketAccessorNode(o)
        raise
      end

      %w{ NewExprNode }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise
        end
      end

      %w{ FunctionExprNode }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise
        end
      end

      private
      def indent; ' ' * @indent * 2; end
    end
  end
end
