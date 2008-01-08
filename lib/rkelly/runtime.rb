require 'rkelly/js'
require 'rkelly/runtime/scope_chain'

module RKelly
  class Runtime
    UNDEFINED = RKelly::JS::Property.new(:undefined, :undefined)

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
          RKelly::JS::Property.new(:param, x)
        }))
      }.value
    end

    def define_function(function, &block)
      @scope[function.to_s].value = block
    end
  end
end
