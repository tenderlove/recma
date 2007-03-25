class RKelly
  class Node < Array
    attr_accessor :type, :value, :lineno, :start, :end, :tokenizer, :initializer
    attr_accessor :name, :params, :funDecls, :varDecls, :body, :functionForm
    attr_accessor :assignOp, :expression, :condition, :thenPart, :elsePart
    attr_accessor :readOnly, :isLoop, :setup, :postfix, :update, :exception
    attr_accessor :object, :iterator, :varDecl, :label, :target, :tryBlock
    attr_accessor :catchClauses, :varName, :guard, :block, :discriminant, :cases
    attr_accessor :defaultIndex, :caseLabel, :statements, :statement
    attr_accessor :finallyBlock

    include Comparable

    def <=>(other)
      object_id <=> other.object_id
    end

    def pretty_print(q)
      q.object_group(self) {
        q.breakable; q.group(1, '{type', '}') {
          q.breakable
          q.pp TOKENS[type]
        }
        
        [ :name, :value, :lineno, :start, :end, :tokenizer, :initializer,
        :params, :funDecls, :varDecls, :body, :functionForm,
        :assignOp, :expression, :condition, :thenPart, :elsePart,
        :readOnly, :isLoop, :setup, :postfix, :update, :exception,
        :object, :iterator, :varDecl, :label, :target, :tryBlock,
        :catchClauses, :varName, :guard, :block, :discriminant, :cases,
        :defaultIndex, :caseLabel, :statements, :statement,
        :finallyBlock ].each { |sym|
          q.breakable; q.group(1, "{#{sym.to_s}", '}') {
            q.breakable
            q.pp send(sym)
          }
        }
      }
    end

    def initialize (t, type = nil)
      token = t.token
      if token
        if type != nil
          @type = type
        else
          @type = token.type
        end
        @value = token.value
        @lineno = token.lineno
        @start = token.start
        @end = token.end
      else
        @type = type
        @lineno = t.lineno
      end
      @tokenizer = t
      #for (var i = 2; i < arguments.length; i++)
      #this.push(arguments[i]);
    end
  
    # Always use push to add operands to an expression, to update start and end.
    def push(kid)
      if kid.start and @start
        @start = kid.start if kid.start < @start
      end
      if kid.end and @end
        @end = kid.end if @end < kid.end
      end
      super(kid)
    end
  
    def getSource
      return @tokenizer.source.slice(@start, @end)
    end
  end
end
