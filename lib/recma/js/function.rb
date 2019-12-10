module RECMA
  module JS
    class Function < Base
      class << self
        def create(*args)
          if args.length > 0
            parser = RECMA::Parser.new
            body = args.pop
            tree = parser.parse("function x(#{args.join(',')}) { #{body} }")
            func = tree.value.first
            self.new(func.function_body, func.arguments)
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
        self['prototype'] = JS::FunctionPrototype.new(self)
        self['toString'] = :undefined
        self['length'] = arguments.length
      end

      def js_call(scope_chain, *params)
        arguments.each_with_index { |name, i|
          scope_chain[name.value] = params[i] || RECMA::Runtime::UNDEFINED
        }
        function_visitor  = RECMA::Visitors::FunctionVisitor.new(scope_chain)
        eval_visitor      = RECMA::Visitors::EvaluationVisitor.new(scope_chain)
        body.accept(function_visitor) if body
        body.accept(eval_visitor) if body
      end
    end
  end
end
