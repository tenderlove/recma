require 'rkelly/runtime/scope'
require 'rkelly/runtime/scope_chain'
require 'rkelly/js'

module RKelly
  class Runtime
    UNDEFINED = RKelly::Runtime::Reference.new(:undefined, :undefined)

    def initialize
      @parser = Parser.new
      @scope  = ScopeChain.new
    end

    # Execute +js+
    def execute(js)
      function_visitor  = Visitors::FunctionVisitor.new(@scope)
      var_visitor       = Visitors::VariableVisitor.new(@scope)
      tree = @parser.parse(js)
      function_visitor.accept(tree)
      var_visitor.accept(tree)
      @scope
    end

    def call_function(function_name, *args)
      function = @scope[function_name].value
      @scope.new_scope { |chain|
        function.js_call(chain, *(args.map { |x|
          RKelly::Runtime::Reference.new(:param, x)
        }))
      }.value
    end

    def define_function(function, &block)
      @scope[function.to_s].value = block
    end
  end
end
