module RKelly
  module Visitors
    class EvaluationVisitor < Visitor
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
        o.value.accept(self) if o.value
        @operand.pop
      end

      def visit_IfNode(o)
        truthiness = o.conditions.accept(self)
        if truthiness.value && truthiness.value != 0
          o.value.accept(self)
        else
          o.else && o.else.accept(self)
        end
      end

      def visit_ResolveNode(o)
        scope_chain[o.value]
      end

      def visit_ThisNode(o)
        scope_chain.this
      end

      def visit_ExpressionStatementNode(o)
        o.value.accept(self)
      end

      def visit_AddNode(o)
        RKelly::JS::Property.new(:add,
          o.left.accept(self).value + o.value.accept(self).value
        )
      end

      def visit_SubtractNode(o)
        RKelly::JS::Property.new(:subtract,
          o.left.accept(self).value - o.value.accept(self).value
        )
      end

      def visit_MultiplyNode(o)
        RKelly::JS::Property.new(:multiply,
          o.left.accept(self).value * o.value.accept(self).value
        )
      end

      def visit_DivideNode(o)
        RKelly::JS::Property.new(:divide,
          o.left.accept(self).value / o.value.accept(self).value
        )
      end

      def visit_OpEqualNode(o)
        left = o.left.accept(self)
        right = o.value.accept(self)
        left.value = right.value
        left.function = right.function
        left
      end

      def visit_OpPlusEqualNode(o)
        o.left.accept(self).value += o.value.accept(self).value
      end

      def visit_AssignExprNode(o)
        scope_chain[@operand.last] = o.value.accept(self)
      end

      def visit_NumberNode(o)
        RKelly::JS::Property.new(o.value, o.value)
      end

      def visit_VoidNode(o)
        o.value.accept(self)
        RKelly::JS::Property.new(:undefined, :undefined)
      end

      def visit_NullNode(o)
        RKelly::JS::Property.new(nil, nil)
      end

      def visit_TrueNode(o)
        RKelly::JS::Property.new(true, true)
      end

      def visit_FalseNode(o)
        RKelly::JS::Property.new(false, false)
      end

      def visit_StringNode(o)
        RKelly::JS::Property.new(:string,
          o.value.gsub(/\A['"]/, '').gsub(/['"]$/, '')
        )
      end

      def visit_FunctionCallNode(o)
        left      = o.value.accept(self)
        arguments = o.arguments.accept(self)
        call_function(left, arguments)
      end

      def visit_NewExprNode(o)
        visit_FunctionCallNode(o)
      end

      def visit_DotAccessorNode(o)
        left = o.value.accept(self)
        right = left.value[o.accessor]
        right.binder = left.value
        right
      end

      def visit_EqualNode(o)
        left = o.left.accept(self)
        right = o.value.accept(self)

        RKelly::JS::Property.new(:equal_node, left.value == right.value)
      end

      def visit_BlockNode(o)
        o.value.accept(self)
      end

      def visit_FunctionBodyNode(o)
        o.value.accept(self)
        scope_chain.return
      end

      def visit_ReturnNode(o)
        scope_chain.return = o.value.accept(self)
      end

      def visit_PostfixNode(o)
        orig = o.operand.accept(self)
        number = to_number(orig)
        orig.value = number.value + 1
        number
      end

      def visit_ArgumentsNode(o)
        o.value.map { |x| x.accept(self) }
      end

      def visit_TypeOfNode(o)
        val = o.value.accept(self)
        return RKelly::JS::Property.new(:string, 'object') if val.value.nil?

        case val.value
        when String
          RKelly::JS::Property.new(:string, 'string')
        when Numeric
          RKelly::JS::Property.new(:string, 'number')
        when true
          RKelly::JS::Property.new(:string, 'boolean')
        when false
          RKelly::JS::Property.new(:string, 'boolean')
        when :undefined
          RKelly::JS::Property.new(:string, 'undefined')
        else
          RKelly::JS::Property.new(:object, 'object')
        end
      end

      def visit_UnaryPlusNode(o)
        v = o.value.accept(self)
        v.value = 0 + v.value
        v
      end

      def visit_UnaryMinusNode(o)
        v = o.value.accept(self)
        v.value = 0 - v.value
        v
      end

      %w{
        ArrayNode BitAndNode BitOrNode
        BitXOrNode BitwiseNotNode BracketAccessorNode BreakNode
        CaseBlockNode CaseClauseNode CommaNode ConditionalNode
        ConstStatementNode ContinueNode DeleteNode
        DoWhileNode ElementNode EmptyStatementNode
        ForInNode ForNode
        FunctionExprNode GetterPropertyNode GreaterNode GreaterOrEqualNode
        InNode InstanceOfNode LabelNode LeftShiftNode LessNode
        LessOrEqualNode LogicalAndNode LogicalNotNode LogicalOrNode ModulusNode
        NotEqualNode NotStrictEqualNode
        ObjectLiteralNode OpAndEqualNode OpDivideEqualNode
        OpLShiftEqualNode OpMinusEqualNode OpModEqualNode
        OpMultiplyEqualNode OpOrEqualNode OpRShiftEqualNode
        OpURShiftEqualNode OpXOrEqualNode ParameterNode PrefixNode
        PropertyNode RegexpNode RightShiftNode
        SetterPropertyNode StrictEqualNode
        SwitchNode ThrowNode TryNode
        UnsignedRightShiftNode
        WhileNode WithNode
      }.each do |type|
        define_method(:"visit_#{type}") do |o|
          raise "#{type} not defined"
        end
      end

      private
      def to_number(object)
        return RKelly::JS::Property.new('0', 0) unless object.value

        return_val =
          case object.value
          when :undefined
            RKelly::JS::NaN.new
          when false
            0
          when true
            1
          when Numeric
            object.value
          when ::String
            s = object.value
            if s.length == 0
              0
            else
              if s =~ /\A-?\d+\.\d*(?:[eE][-+]?\d+)?$|\A-?\d+(?:\.\d*)?[eE][-+]?\d+$|\A-?\.\d+(?:[eE][-+]?\d+)?$/ || s =~ /\A-?0[xX][\da-fA-F]+$|\A-?0[0-7]*$|\A-?\d+$/
                s = s.gsub(/^[0]*/, '') if /^\d+$/.match(s)
                eval(s)
              else
                RKelly::JS::NaN.new
              end
            end
          when RKelly::JS::Base
            return to_number(to_primitive(object, 'Number'))
          end
        RKelly::JS::Property.new(nil, return_val)
      end

      def to_primitive(object, preferred_type)
        return object unless object.value
        case object.value
        when false, true, :undefined, ::String, Numeric
          object
        when RKelly::JS::Base
          call_function(object.value.default_value(preferred_type))
        end
      end

      def call_function(property, arguments = [])
        function  = property.function || property.value
        case function
        when RKelly::JS::Function
          scope_chain.new_scope { |chain|
            function.js_call(chain, *arguments)
          }
        when UnboundMethod
          RKelly::JS::Property.new(:ruby,
            function.bind(property.binder).call(*(arguments.map { |x| x.value}))
          )
        else
          RKelly::JS::Property.new(:ruby,
            function.call(*(arguments.map { |x| x.value }))
          )
        end
      end
    end
  end
end
