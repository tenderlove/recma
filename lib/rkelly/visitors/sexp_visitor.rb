module RKelly
  module Visitors
    class SexpVisitor < Visitor
      #def visit_Node(o)
      #  [:lit, o.value]
      #end

      def visit_NumberNode(o)
        [:lit, o.value]
      end

      def visit_RegexpNode(o)
        [:lit, o.value]
      end

      def visit_AssignExprNode(o)
        [:assign, o.value.accept(self)]
      end

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

      def visit_DeleteNode(o)
        [:delete, o.value.accept(self)]
      end

      def visit_VoidNode(o)
        [:void, o.value.accept(self)]
      end

      def visit_TypeOfNode(o)
        [:typeof, o.value.accept(self)]
      end

      def visit_UnaryPlusNode(o)
        [:u_plus, o.value.accept(self)]
      end

      def visit_UnaryMinusNode(o)
        [:u_minus, o.value.accept(self)]
      end

      def visit_BitwiseNotNode(o)
        [:bitwise_not, o.value.accept(self)]
      end

      def visit_LogicalNotNode(o)
        [:not, o.value.accept(self)]
      end

      def visit_ConstStatementNode(o)
        [:const, o.value.map { |x| x.accept(self) }]
      end

      def visit_MultiplyNode(o)
        [:multiply, o.left.accept(self), o.value.accept(self)]
      end

      def visit_DivideNode(o)
        [:divide, o.left.accept(self), o.value.accept(self)]
      end

      def visit_ModulusNode(o)
        [:modulus, o.left.accept(self), o.value.accept(self)]
      end

      def visit_AddNode(o)
        [:add, o.left.accept(self), o.value.accept(self)]
      end

      def visit_LeftShiftNode(o)
        [:lshift, o.left.accept(self), o.value.accept(self)]
      end

      def visit_RightShiftNode(o)
        [:rshift, o.left.accept(self), o.value.accept(self)]
      end

      def visit_UnsignedRightShiftNode(o)
        [:urshift, o.left.accept(self), o.value.accept(self)]
      end

      def visit_SubtractNode(o)
        [:subtract, o.left.accept(self), o.value.accept(self)]
      end

      def visit_LessNode(o)
        [:less, o.left.accept(self), o.value.accept(self)]
      end

      def visit_GreaterNode(o)
        [:greater, o.left.accept(self), o.value.accept(self)]
      end

      def visit_LessOrEqualNode(o)
        [:less_or_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_GreaterOrEqualNode(o)
        [:greater_or_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_InstanceOfNode(o)
        [:instance_of, o.left.accept(self), o.value.accept(self)]
      end

      def visit_EqualNode(o)
        [:equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_NotEqualNode(o)
        [:not_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_StrictEqualNode(o)
        [:strict_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_NotStrictEqualNode(o)
        [:not_strict_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_BitAndNode(o)
        [:bit_and, o.left.accept(self), o.value.accept(self)]
      end

      def visit_BitOrNode(o)
        [:bit_or, o.left.accept(self), o.value.accept(self)]
      end

      def visit_BitXOrNode(o)
        [:bit_xor, o.left.accept(self), o.value.accept(self)]
      end

      def visit_LogicalAndNode(o)
        [:and, o.left.accept(self), o.value.accept(self)]
      end

      def visit_LogicalOrNode(o)
        [:or, o.left.accept(self), o.value.accept(self)]
      end

      def visit_InNode(o)
        [:in, o.left.accept(self), o.value.accept(self)]
      end

      def visit_DoWhileNode(o)
        [:do_while, o.left.accept(self), o.value.accept(self)]
      end

      def visit_WhileNode(o)
        [:while, o.left.accept(self), o.value.accept(self)]
      end

      def visit_ForNode(o)
        [ :for,
          o.init ? o.init.accept(self) : nil,
          o.test ? o.test.accept(self) : nil,
          o.counter ? o.counter.accept(self) : nil,
          o.value.accept(self)
        ]
      end

      def visit_BlockNode(o)
        [:block, o.value.accept(self)]
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

      def visit_EmptyStatementNode(o)
        [:empty]
      end

      def visit_FunctionBodyNode(o)
        [:func_body, o.value.accept(self)]
      end

      def visit_SourceElements(o)
        o.value.map { |x| x.accept(self) }
      end

      def visit_ResolveNode(o)
        [:resolve, o.value]
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

      def visit_ParameterNode(o)
        [:param, o.value]
      end

      def visit_BreakNode(o)
        [:break, o.value].compact
      end

      def visit_ContinueNode(o)
        [:continue, o.value].compact
      end

      def visit_LabelNode(o)
        [:label, o.name, o.value.accept(self)]
      end

      def visit_ThrowNode(o)
        [:throw, o.value.accept(self)]
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

      def visit_ElementNode(o)
        [:element, o.value.accept(self)]
      end

      def visit_ExpressionStatementNode(o)
        [:expression, o.value.accept(self)]
      end

      def visit_OpEqualNode(o)
        [:op_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpPlusEqualNode(o)
        [:op_plus_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpMinusEqualNode(o)
        [:op_minus_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpMultiplyEqualNode(o)
        [:op_multiply_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpDivideEqualNode(o)
        [:op_divide_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpLShiftEqualNode(o)
        [:op_lshift_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpRShiftEqualNode(o)
        [:op_rshift_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpURShiftEqualNode(o)
        [:op_urshift_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpAndEqualNode(o)
        [:op_and_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpXOrEqualNode(o)
        [:op_xor_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpOrEqualNode(o)
        [:op_or_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_OpModEqualNode(o)
        [:op_mod_equal, o.left.accept(self), o.value.accept(self)]
      end

      def visit_CommaNode(o)
        [:comma, o.left.accept(self), o.value.accept(self)]
      end

      def visit_FunctionCallNode(o)
        [:function_call, o.value.accept(self), o.arguments.accept(self)]
      end

      def visit_ArrayNode(o)
        [:array, o.value.map { |x| x ? x.accept(self) : nil }]
      end

      def visit_ThisNode(o)
        [:this]
      end

      def visit_ReturnNode(o)
        o.value ? [:return, o.value.accept(self)] : [:return]
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

      def visit_NullNode(o)
        [:nil]
      end
      
      def visit_StringNode(o)
        [:str, o.value]
      end

      def visit_FalseNode(o)
        [:false]
      end

      def visit_TrueNode(o)
        [:true]
      end

    end
  end
end
