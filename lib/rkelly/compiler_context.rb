class RKelly
  class CompilerContext
    attr_accessor :inFunction, :stmtStack, :funDecls, :varDecls
    attr_accessor :bracketLevel, :curlyLevel, :parenLevel, :hookLevel
    attr_accessor :ecmaStrictMode, :inForLoopInit
  
    def initialize (inFunction)
      @inFunction = inFunction
      @stmtStack = []
      @funDecls = []
      @varDecls = []
      
      @bracketLevel = @curlyLevel = @parenLevel = @hookLevel = 0
      @ecmaStrictMode = @inForLoopInit = false
    end
  end
end
