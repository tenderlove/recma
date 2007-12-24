module RKelly
  module Visitors
    class DotVisitor < Visitor
      class Node < Struct.new(:node_id, :fields)
        def to_s
          counter = 0
          label = fields.map { |f|
            s = "<f#{counter}> #{f}"
            counter += 1
            s
          }.join('|')
          "\"#{node_id}\" [\nlabel = \"#{label}\"\nshape = \"record\"\n];"
        end
      end

      class Arrow < Struct.new(:from, :to)
        def to_s
          "\"#{from.node_id}\":f0 -> \"#{to.node_id}\":f0"
        end
      end

      attr_reader :nodes, :arrows
      def initialize
        @stack = []
        @node_index = 0
        @nodes  = []
        @arrows = []
      end

      def add_arrow_for(node)
        @arrows << Arrow.new(@stack.last, node) if @stack.length > 0
      end

      ## Terminal nodes
      %w{
        BreakNode ContinueNode ContinueNode EmptyStatementNode FalseNode
        NullNode NumberNode ParameterNode RegexpNode ResolveNode StringNode
        ThisNode TrueNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          node = Node.new(@node_index += 1, [type, o.value].compact)
          add_arrow_for(node)
          @nodes << node
        end
      end
      ## End Terminal nodes

      # Single value nodes
      %w{
        AssignExprNode BitwiseNotNode BlockNode DeleteNode ElementNode
        ExpressionStatementNode FunctionBodyNode LogicalNotNode ReturnNode
        ThrowNode TypeOfNode UnaryMinusNode UnaryPlusNode VoidNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          node = Node.new(@node_index += 1, [type])
          add_arrow_for(node)
          @nodes << node
          @stack.push(node)
          o.value.accept(self)
          @stack.pop
        end
      end
      # End Single value nodes

      # Binary nodes
      %w{
        AddNode BitAndNode BitOrNode BitXOrNode CaseClauseNode CommaNode
        DivideNode DoWhileNode EqualNode GreaterNode GreaterOrEqualNode InNode
        InstanceOfNode LeftShiftNode LessNode LessOrEqualNode LogicalAndNode
        LogicalOrNode ModulusNode MultiplyNode NotEqualNode NotStrictEqualNode
        OpAndEqualNode OpDivideEqualNode OpEqualNode OpLShiftEqualNode
        OpMinusEqualNode OpModEqualNode OpMultiplyEqualNode OpOrEqualNode
        OpPlusEqualNode OpRShiftEqualNode OpURShiftEqualNode OpXOrEqualNode
        RightShiftNode StrictEqualNode SubtractNode SwitchNode
        UnsignedRightShiftNode WhileNode WithNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          node = Node.new(@node_index += 1, [type])
          add_arrow_for(node)
          @nodes << node
          @stack.push(node)
          o.left && o.left.accept(self)
          o.value && o.value.accept(self)
          @stack.pop
        end
      end
      # End Binary nodes

      def visit_VarDeclNode(o)
        [ o.constant? ? :const_decl : :var_decl,
          o.name.to_sym, o.value ? o.value.accept(self) : nil]
      end

      def visit_VarStatementNode(o)
        [:var, o.value.map { |x| x.accept(self) }]
      end

      def visit_PostfixNode(o)
        [:postfix, o.operand.accept(self), o.value]
      end

      def visit_PrefixNode(o)
        [:prefix, o.operand.accept(self), o.value]
      end

      def visit_ConstStatementNode(o)
        [:const, o.value.map { |x| x.accept(self) }]
      end

      def visit_CaseBlockNode(o)
        [:case_block, o.value.map { |x| x.accept(self) }]
      end

      def visit_ForNode(o)
        [ :for,
          o.init ? o.init.accept(self) : nil,
          o.test ? o.test.accept(self) : nil,
          o.counter ? o.counter.accept(self) : nil,
          o.value.accept(self)
        ]
      end

      def visit_IfNode(o)
        [:if, o.conditions.accept(self),
              o.value.accept(self),
              o.else ? o.else.accept(self) : nil
        ].compact
      end

      def visit_ConditionalNode(o)
        [:conditional, o.conditions.accept(self),
              o.value.accept(self),
              o.else.accept(self)
        ]
      end

      def visit_ForInNode(o)
        [ :for_in,
          o.left.accept(self),
          o.right.accept(self),
          o.value.accept(self)
        ]
      end

      def visit_TryNode(o)
        [ :try,
          o.value.accept(self),
          o.catch_var ? o.catch_var : nil,
          o.catch_block ? o.catch_block.accept(self) : nil,
          o.finally_block ? o.finally_block.accept(self) : nil
        ]
      end

      def visit_SourceElements(o)
        o.value.map { |x| x.accept(self) }
      end

      def visit_BracketAccessorNode(o)
        [:bracket_access,
          o.value.accept(self),
          o.accessor.accept(self)
        ]
      end

      def visit_NewExprNode(o)
        [:new_expr, o.value.accept(self), o.arguments.accept(self)]
      end

      def visit_LabelNode(o)
        [:label, o.name, o.value.accept(self)]
      end

      def visit_ObjectLiteralNode(o)
        [:object, o.value.map { |x| x.accept(self) }]
      end

      def visit_PropertyNode(o)
        [ :property, o.name, o.value.accept(self) ]
      end

      def visit_GetterPropertyNode(o)
        [ :getter, o.name, o.value.accept(self) ]
      end

      def visit_SetterPropertyNode(o)
        [ :setter, o.name, o.value.accept(self) ]
      end

      def visit_FunctionCallNode(o)
        [:function_call, o.value.accept(self), o.arguments.accept(self)]
      end

      def visit_ArrayNode(o)
        [:array, o.value.map { |x| x ? x.accept(self) : nil }]
      end

      def visit_FunctionExprNode(o)
        [ :func_expr,
          o.value ? o.value : nil,
          o.arguments.map { |x| x.accept(self) },
          o.function_body.accept(self)
        ]
      end

      def visit_FunctionDeclNode(o)
        [ :func_decl,
          o.value ? o.value : nil,
          o.arguments.map { |x| x.accept(self) },
          o.function_body.accept(self)
        ]
      end

      def visit_ArgumentsNode(o)
        [:args, o.value.map { |x| x.accept(self) }]
      end

      def visit_DotAccessorNode(o)
        [:dot_access,
          o.value.accept(self),
          o.accessor
        ]
      end
    end
  end
end
