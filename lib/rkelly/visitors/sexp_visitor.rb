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

      def visit_ConstStatementNode(o)
        [:const, o.value.map { |x| x.accept(self) }]
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
