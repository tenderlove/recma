module RKelly
  module JS
    class Function
      attr_reader :body, :arguments
      def initialize(body, arguments = [])
        @body = body
        @arguments = arguments
      end

      def js_call(scope_chain, *params)
        arguments.each_with_index { |name, i|
          scope_chain[name.value] = params[i] || RKelly::Runtime::UNDEFINED
        }
        function_visitor  = RKelly::Visitors::FunctionVisitor.new(scope_chain)
        var_visitor       = RKelly::Visitors::VariableVisitor.new(scope_chain)
        body.accept(function_visitor)
        body.accept(var_visitor)
      end
    end
  end
end
