module RKelly
  module Visitors
    class VariableVisitor < Visitor
      attr_reader :scope_chain
      def initialize(scope)
        super()
        @scope_chain = scope
        @operand = []
      end

      def visit_SourceElements(o)
        o.value.each { |x|
          next if scope_chain.returned?
          x.accept(self)
        }
      end

      def visit_FunctionDeclNode(o)
      end

      def visit_VarStatementNode(o)
        o.value.each { |x| x.accept(self) }
      end

      def visit_VarDeclNode(o)
        @operand << o.name
        o.value.accept(self)
        @operand.pop
      end

      def visit_ResolveNode(o)
        scope_chain[o.value]
      end

      def visit_ExpressionStatementNode(o)
        o.value.accept(self)
      end

      def visit_AddNode(o)
        o.left.accept(self) + o.value.accept(self)
      end

      def visit_SubtractNode(o)
        o.left.accept(self) - o.value.accept(self)
      end

      def visit_MultiplyNode(o)
        o.left.accept(self) * o.value.accept(self)
      end

      def visit_DivideNode(o)
        o.left.accept(self) / o.value.accept(self)
      end

      def visit_OpEqualNode(o)
        o.left.accept(self).value = o.value.accept(self)
      end

      def visit_OpPlusEqualNode(o)
        o.left.accept(self).value += o.value.accept(self)
      end

      def visit_AssignExprNode(o)
        scope_chain[@operand.last].value = o.value.accept(self)
      end

      def visit_NumberNode(o)
        o.value
      end

      def visit_VoidNode(o)
        o.value.accept(self)
        :undefined
      end

      def visit_FunctionCallNode(o)
        function  = o.value.accept(self).value
        arguments = o.arguments.accept(self)
        if function.is_a?(RKelly::Visitors::Function)
          scope_chain.new_scope { |chain|
            function.js_call(chain, *arguments)
          }
        else
          function.call(*arguments)
        end
      end

      def visit_EqualNode(o)
        o.left.accept(self).value == o.value.accept(self).value
      end

      def visit_FunctionBodyNode(o)
        o.value.accept(self)
        scope_chain.return
      end

      def visit_ReturnNode(o)
        scope_chain.return = o.value.accept(self)
      end

      def visit_ArgumentsNode(o)
        o.value.map { |x| x.accept(self) }
      end

      %w{
        ArrayNode BitAndNode BitOrNode
        BitXOrNode BitwiseNotNode BlockNode BracketAccessorNode BreakNode
        CaseBlockNode CaseClauseNode CommaNode ConditionalNode
        ConstStatementNode ContinueNode ContinueNode DeleteNode
        DoWhileNode DotAccessorNode ElementNode EmptyStatementNode
        FalseNode ForInNode ForNode
        FunctionExprNode GetterPropertyNode GreaterNode GreaterOrEqualNode
        IfNode InNode InstanceOfNode LabelNode LeftShiftNode LessNode
        LessOrEqualNode LogicalAndNode LogicalNotNode LogicalOrNode ModulusNode
        NewExprNode NotEqualNode NotStrictEqualNode NullNode
        ObjectLiteralNode OpAndEqualNode OpDivideEqualNode
        OpLShiftEqualNode OpMinusEqualNode OpModEqualNode
        OpMultiplyEqualNode OpOrEqualNode OpRShiftEqualNode
        OpURShiftEqualNode OpXOrEqualNode ParameterNode PostfixNode PrefixNode
        PropertyNode RegexpNode RightShiftNode
        SetterPropertyNode StrictEqualNode StringNode
        SwitchNode ThisNode ThrowNode TrueNode TryNode TypeOfNode
        UnaryMinusNode UnaryPlusNode UnsignedRightShiftNode
        WhileNode WithNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise "#{type} not defined"
        end
      end
    end
  end
end
