module RKelly
  module JS
    class Function < Base
      class << self
        def create(*args)
          if args.length > 0
            parser = RKelly::Parser.new
            body = args.pop
            arguments = args.map { |x| RKelly::Nodes::ParameterNode.new(x) }
            body = RKelly::Nodes::FunctionBodyNode.new(parser.parse(body))
            self.new(body, arguments)
          else
            self.new
          end
        end
      end

      attr_reader :body, :arguments
      def initialize(body = nil, arguments = [])
        super()
        @body = body
        @arguments = arguments
        self['toString'] = :undefined
      end

      def js_call(scope_chain, *params)
        arguments.each_with_index { |name, i|
          scope_chain[name.value] = params[i] || RKelly::Runtime::UNDEFINED
        }
        function_visitor  = RKelly::Visitors::FunctionVisitor.new(scope_chain)
        eval_visitor      = RKelly::Visitors::EvaluationVisitor.new(scope_chain)
        body.accept(function_visitor) if body
        body.accept(eval_visitor) if body
      end
    end
  end
end
