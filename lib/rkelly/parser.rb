class RKelly
  def initialize
    @function_cache = {}
    @class_cache = {}
  end

  def script(t, x)
    n = statements(t, x)
    n.type = CONSTS["SCRIPT"]
    n.funDecls = x.funDecls
    n.varDecls = x.varDecls
    return n
  end

  # statement stack and nested statement handler.
  # nb. Narcissus allowed a function reference, here we use statement explicitly
  def nest(t, x, node, end_ = nil)
    x.stmtStack.push(node)
    n = statement(t, x)
    x.stmtStack.pop
    end_ and t.mustMatch(end_)
    return n
  end

  def statements(t, x)
    n = Node.new(t, CONSTS["BLOCK"])
    x.stmtStack.push(n)
    n.push(statement(t, x)) while !t.done and t.peek != CONSTS["RIGHT_CURLY"]
    x.stmtStack.pop
    return n
  end

  def block(t, x)
    t.mustMatch(CONSTS["LEFT_CURLY"])
    n = statements(t, x)
    t.mustMatch(CONSTS["RIGHT_CURLY"])
    return n
  end

  def statement(t, x)
    tt = t.get
  
    # Cases for statements ending in a right curly return early, avoiding the
    # common semicolon insertion magic after this switch.
    case tt
      when CONSTS["FUNCTION"]
        return function_definition(t, x, true, 
          (x.stmtStack.length > 1) && STATEMENT_FORM || DECLARED_FORM)
  
      when CONSTS["LEFT_CURLY"]
        n = statements(t, x)
        t.mustMatch(CONSTS["RIGHT_CURLY"])
        return n
      
      when CONSTS["IF"]
        n = Node.new(t)
        n.condition = paren_expression(t, x)
        x.stmtStack.push(n)
        n.thenPart = statement(t, x)
        n.elsePart = t.match(CONSTS["ELSE"]) ? statement(t, x) : nil
        x.stmtStack.pop()
        return n
  
      when CONSTS["SWITCH"]
        n = Node.new(t)
        t.mustMatch(CONSTS["LEFT_PAREN"])
        n.discriminant = expression(t, x)
        t.mustMatch(CONSTS["RIGHT_PAREN"])
        n.cases = []
        n.defaultIndex = -1
        x.stmtStack.push(n)
        t.mustMatch(CONSTS["LEFT_CURLY"])
        while (tt = t.get) != CONSTS["RIGHT_CURLY"]
          case tt
            when CONSTS["DEFAULT"], CONSTS["CASE"]
              if tt == CONSTS["DEFAULT"] and n.defaultIndex >= 0
                raise SyntaxError.new("More than one switch default", t)
              end
              n2 = Node.new(t)
              if tt == CONSTS["DEFAULT"]
                n.defaultIndex = n.cases.length
              else
                n2.caseLabel = expression(t, x, CONSTS["COLON"])
              end
            
            else
              raise SyntaxError.new("Invalid switch case", t)
          end
          t.mustMatch(CONSTS["COLON"])
          n2.statements = Node.new(t, CONSTS["BLOCK"])
          while (tt = t.peek) != CONSTS["CASE"] and tt != CONSTS["DEFAULT"] and tt != CONSTS["RIGHT_CURLY"]
            n2.statements.push(statement(t, x))
          end
          n.cases.push(n2)
        end
        x.stmtStack.pop
        return n
      
      when CONSTS["FOR"]
        n = Node.new(t)
        n.isLoop = true
        t.mustMatch(CONSTS["LEFT_PAREN"])
        if (tt = t.peek) != CONSTS["SEMICOLON"]
          x.inForLoopInit = true
          if tt == CONSTS["VAR"] or tt == CONSTS["CONST"]
            t.get
            n2 = variables(t, x)
          else
            n2 = expression(t, x)
          end
          x.inForLoopInit = false
        end
        if n2 and t.match(CONSTS["IN"])
          n.type = CONSTS["FOR_IN"]
          if n2.type == CONSTS["VAR"]
            if n2.length != 1
              raise SyntaxError.new("Invalid for..in left-hand side", t)
            end
            # NB: n2[0].type == IDENTIFIER and n2[0].value == n2[0].name.
            n.iterator = n2[0]
            n.varDecl = n2
          else
            n.iterator = n2
            n.varDecl = nil
          end
          n.object = expression(t, x)
        else
          n.setup = n2 or nil
          t.mustMatch(CONSTS["SEMICOLON"])
          n.condition = (t.peek == CONSTS["SEMICOLON"]) ? nil : expression(t, x)
          t.mustMatch(CONSTS["SEMICOLON"])
          n.update = (t.peek == CONSTS["RIGHT_PAREN"]) ? nil : expression(t, x)
        end
        t.mustMatch(CONSTS["RIGHT_PAREN"])
        n.body = nest(t, x, n)
        return n
      
      when CONSTS["WHILE"]
        n = Node.new(t)
        n.isLoop = true
        n.condition = paren_expression(t, x)
        n.body = nest(t, x, n)
        return n
      
      when CONSTS["DO"]
        n = Node.new(t)
        n.isLoop = true
        n.body = nest(t, x, n, CONSTS["WHILE"])
        n.condition = paren_expression(t, x)
        if !x.ecmaStrictMode
          # <script language="JavaScript"> (without version hints) may need
          # automatic semicolon insertion without a newline after do-while.
          # See http://bugzilla.mozilla.org/show_bug.cgi?id=238945.
          t.match(CONSTS["SEMICOLON"])
          return n
        end
      
      when CONSTS["BREAK"], CONSTS["CONTINUE"]
        n = Node.new(t)
        if t.peekOnSameLine == CONSTS["IDENTIFIER"]
          t.get
          n.label = t.token.value
        end
        ss = x.stmtStack
        i = ss.length
        label = n.label
        if label
          begin
            i -= 1
            raise SyntaxError.new("Label not found", t) if i < 0
          end while (ss[i].label != label)
        else
          begin
            i -= 1
            raise SyntaxError.new("Invalid " + ((tt == CONSTS["BREAK"]) and "break" or "continue"), t) if i < 0
          end while !ss[i].isLoop and (tt != CONSTS["BREAK"] or ss[i].type != CONSTS["SWITCH"])
        end
        n.target = ss[i]
      
      when CONSTS["TRY"]
        n = Node.new(t)
        n.tryBlock = block(t, x)
        n.catchClauses = []
        while t.match(CONSTS["CATCH"])
          n2 = Node.new(t)
          t.mustMatch(CONSTS["LEFT_PAREN"])
          n2.varName = t.mustMatch(CONSTS["IDENTIFIER"]).value
          if t.match(CONSTS["IF"])
            raise SyntaxError.new("Illegal catch guard", t) if x.ecmaStrictMode
            if n.catchClauses.length and !n.catchClauses.last.guard
              raise SyntaxError.new("Guarded catch after unguarded", t)
            end
            n2.guard = expression(t, x)
          else
            n2.guard = nil
          end
          t.mustMatch(CONSTS["RIGHT_PAREN"])
          n2.block = block(t, x)
          n.catchClauses.push(n2)
        end
        n.finallyBlock = block(t, x) if t.match(CONSTS["FINALLY"])
        if !n.catchClauses.length and !n.finallyBlock
          raise SyntaxError.new("Invalid try statement", t)
        end
        return n
      
      when CONSTS["CATCH"]
      when CONSTS["FINALLY"]
        raise SyntaxError.new(tokens[tt] + " without preceding try", t)
      
      when CONSTS["THROW"]
        n = Node.new(t)
        n.exception = expression(t, x)
      
      when CONSTS["RETURN"]
        raise SyntaxError.new("Invalid return", t) unless x.inFunction
        n = Node.new(t)
        tt = t.peekOnSameLine
        if tt != CONSTS["END"] and tt != CONSTS["NEWLINE"] and tt != CONSTS["SEMICOLON"] and tt != CONSTS["RIGHT_CURLY"]
          n.value = expression(t, x)
        end
      
      when CONSTS["WITH"]
        n = Node.new(t)
        n.object = paren_expression(t, x)
        n.body = nest(t, x, n)
        return n
      
      when CONSTS["VAR"], CONSTS["CONST"]
        n = variables(t, x)
      
      when CONSTS["DEBUGGER"]
        n = Node.new(t)
    
      when CONSTS["NEWLINE"], CONSTS["SEMICOLON"]
        n = Node.new(t, CONSTS["SEMICOLON"])
        n.expression = nil
        return n
  
      else
        if tt == CONSTS["IDENTIFIER"] and t.peek == CONSTS["COLON"]
          label = t.token.value
          ss = x.stmtStack
          (ss.length - 1).times do |i|
            raise SyntaxError.new("Duplicate label", t) if ss[i].label == label
          end
          t.get
          n = Node.new(t, CONSTS["LABEL"])
          n.label = label
          n.statement = nest(t, x, n)
          return n
        end
  
        t.unget
        n = Node.new(t, CONSTS["SEMICOLON"])
        n.expression = expression(t, x)
        n.end = n.expression.end
    end
  
    if t.lineno == t.token.lineno
      tt = t.peekOnSameLine
      if tt != CONSTS["END"] and tt != CONSTS["NEWLINE"] and tt != CONSTS["SEMICOLON"] and tt != CONSTS["RIGHT_CURLY"]
        raise SyntaxError.new("Missing ; before statement", t)
      end
    end
    t.match(CONSTS["SEMICOLON"])
    return n
  end


  def function_definition(t, x, requireName, functionForm)
    f = Node.new(t)
    if f.type != CONSTS["FUNCTION"]
      f.type = (f.value == "get") and CONSTS["GETTER"] or CONSTS["SETTER"]
    end
    if t.match(CONSTS["IDENTIFIER"])
      f.name = t.token.value
    elsif requireName
      raise SyntaxError.new("Missing function identifier", t)
    end
    t.mustMatch(CONSTS["LEFT_PAREN"])
    f.params = []
    while (tt = t.get) != CONSTS["RIGHT_PAREN"]
      raise SyntaxError.new("Missing formal parameter", t) unless tt == CONSTS["IDENTIFIER"]
      f.params.push(t.token.value)
      t.mustMatch(CONSTS["COMMA"]) unless t.peek == CONSTS["RIGHT_PAREN"]
    end
    
    t.mustMatch(CONSTS["LEFT_CURLY"])
    x2 = CompilerContext.new(true)
    f.body = script(t, x2)
    t.mustMatch(CONSTS["RIGHT_CURLY"])
    f.end = t.token.end
    f.functionForm = functionForm
    x.funDecls.push(f) if functionForm == CONSTS["DECLARED_FORM"]
    return f
  end


  def variables(t, x)
    n = Node.new(t)
    begin
      t.mustMatch(CONSTS["IDENTIFIER"])
      n2 = Node.new(t)
      n2.name = n2.value
      if t.match(CONSTS["ASSIGN"])
        raise SyntaxError.new("Invalid variable initialization", t) if t.token.assignOp
        n2.initializer = expression(t, x, CONSTS["COMMA"])
      end
      n2.readOnly = (n.type == CONSTS["CONST"])
      n.push(n2)
      x.varDecls.push(n2)
    end while t.match(CONSTS["COMMA"])
    return n
  end


  def paren_expression(t, x)
    t.mustMatch(CONSTS["LEFT_PAREN"])
    n = expression(t, x)
    t.mustMatch(CONSTS["RIGHT_PAREN"])
    return n
  end

  def reduce(operators, operands, t)
    n = operators.pop
    op = n.type
    arity = OPARITY[op]
    if arity == -2
      if operands.length >= 2
        # Flatten left-associative trees.
        left = operands[operands.length - 2]
        
        if left.type == op
          right = operands.pop
          left.push(right)
          return left
        end
      end
      arity = 2
    end
    
    # Always use push to add operands to n, to update start and end.
    a = operands.slice!(operands.length - arity, operands.length)
  
    arity.times do |i|
      n.push(a[i])
    end
    
    # Include closing bracket or postfix operator in [start,end).
    n.end = t.token.end if n.end < t.token.end
    
    operands.push(n)
    return n
  end

  def expression(t, x, stop = nil)
    operators = []
    operands = []
    bl = x.bracketLevel
    cl = x.curlyLevel
    pl = x.parenLevel
    hl = x.hookLevel
    
  
  gotoloopContinue = false
  until gotoloopContinue or (t.token and t.token.type == CONSTS["END"])
  gotoloopContinue = catch(:gotoloop) do
  #loop:
    while (tt = t.get) != CONSTS["END"]
      # Stop only if tt matches the optional stop parameter, and that
      # token is not quoted by some kind of bracket.
      if tt == stop and x.bracketLevel == bl and x.curlyLevel == cl and x.parenLevel == pl and x.hookLevel == hl
        throw :gotoloop, true
      end
      
      case tt
        when CONSTS["SEMICOLON"]
          # NB: cannot be empty, statement handled that.
          throw :gotoloop, true;
        
        when CONSTS["ASSIGN"], CONSTS["HOOK"], CONSTS["COLON"]
          if t.scanOperand
            throw :gotoloop, true
          end
                  
          # Use >, not >=, for right-associative ASSIGN and HOOK/COLON.
          while operators.length > 0 && OPPRECEDENCE[operators.last.type] && OPPRECEDENCE[operators.last.type] > OPPRECEDENCE[tt]
            reduce(operators, operands, t)
          end
          if tt == CONSTS["COLON"]
            n = operators.last
            raise SyntaxError.new("Invalid label", t) if n.type != CONSTS["HOOK"]
            n.type = CONSTS["CONDITIONAL"]
            x.hookLevel -= 1
          else
            operators.push(Node.new(t))
            if tt == CONSTS["ASSIGN"]
              operands.last.assignOp = t.token.assignOp
            else
              x.hookLevel += 1 # tt == HOOK
            end
          end
          t.scanOperand = true
        
        when CONSTS["COMMA"],
          # Treat comma as left-associative so reduce can fold left-heavy
          # COMMA trees into a single array.
          CONSTS["OR"], CONSTS["AND"], CONSTS["BITWISE_OR"], CONSTS["BITWISE_XOR"],
          CONSTS["BITWISE_AND"], CONSTS["EQ"], CONSTS["NE"], CONSTS["STRICT_EQ"],
          CONSTS["STRICT_NE"], CONSTS["LT"], CONSTS["LE"], CONSTS["GE"],
          CONSTS["GT"], CONSTS["INSTANCEOF"], CONSTS["LSH"], CONSTS["RSH"],
          CONSTS["URSH"], CONSTS["PLUS"], CONSTS["MINUS"], CONSTS["MUL"],
          CONSTS["DIV"], CONSTS["MOD"], CONSTS["DOT"], CONSTS["IN"]
  
          # An in operator should not be parsed if we're parsing the head of
          # a for (...) loop, unless it is in the then part of a conditional
          # expression, or parenthesized somehow.
          if tt == CONSTS["IN"] and x.inForLoopInit and x.hookLevel == 0 and x.bracketLevel == 0 and x.curlyLevel == 0 and x.parenLevel == 0
            throw :gotoloop, true
          end
          
          if t.scanOperand
            throw :gotoloop, true
          end
  
          reduce(operators, operands, t) while operators.length > 0 && OPPRECEDENCE[operators.last.type] && OPPRECEDENCE[operators.last.type] >= OPPRECEDENCE[tt]

          if tt == CONSTS["DOT"]
            t.mustMatch(CONSTS["IDENTIFIER"])
            node = Node.new(t, CONSTS["DOT"])
            node.push(operands.pop)
            node.push(Node.new(t))
            operands.push(node)
          else
            operators.push(Node.new(t))
            t.scanOperand = true
          end
        
        when CONSTS["DELETE"], CONSTS["VOID"], CONSTS["TYPEOF"], CONSTS["NOT"],
          CONSTS["BITWISE_NOT"], CONSTS["UNARY_PLUS"], CONSTS["UNARY_MINUS"],
          CONSTS["NEW"]
  
          if !t.scanOperand
            throw :gotoloop, true
          end
          operators.push(Node.new(t))
        
        when CONSTS["INCREMENT"], CONSTS["DECREMENT"]
          if t.scanOperand
            operators.push(Node.new(t)) # prefix increment or decrement
          else
            # Use >, not >=, so postfix has higher precedence than prefix.
            reduce(operators, operands, t) while operators.length > 0 && OPPRECEDENCE[operators.last.type] && OPPRECEDENCE[operators.last.type] > OPPRECEDENCE[tt]
            n = Node.new(t, tt)
            n.push(operands.pop)
            n.postfix = true
            operands.push(n)
          end
        
        when CONSTS["FUNCTION"]
          if !t.scanOperand
            throw :gotoloop, true
          end
          operands.push(function_definition(t, x, false, CONSTS["EXPRESSED_FORM"]))
          t.scanOperand = false
        
        when CONSTS["NULL"], CONSTS["THIS"], CONSTS["TRUE"], CONSTS["FALSE"],
          CONSTS["IDENTIFIER"], CONSTS["NUMBER"], CONSTS["STRING"],
          CONSTS["REGEXP"]
  
          if !t.scanOperand
            throw :gotoloop, true
          end
          operands.push(Node.new(t))
          t.scanOperand = false
        
        when CONSTS["LEFT_BRACKET"]
          if t.scanOperand
            # Array initialiser.  Parse using recursive descent, as the
            # sub-grammar here is not an operator grammar.
            n = Node.new(t, CONSTS["ARRAY_INIT"])
            while (tt = t.peek) != CONSTS["RIGHT_BRACKET"]
              if tt == CONSTS["COMMA"]
                t.get
                n.push(nil)
                next
              end
              n.push(expression(t, x, CONSTS["COMMA"]))
              break if !t.match(CONSTS["COMMA"])
            end
            t.mustMatch(CONSTS["RIGHT_BRACKET"])
            operands.push(n)
            t.scanOperand = false
          else
            # Property indexing operator.
            operators.push(Node.new(t, CONSTS["INDEX"]))
            t.scanOperand = true
            x.bracketLevel += 1
          end
        
        when CONSTS["RIGHT_BRACKET"]
          if t.scanOperand or x.bracketLevel == bl
            throw :gotoloop, true
          end
          while reduce(operators, operands, t).type != CONSTS["INDEX"]
            nil
          end
          x.bracketLevel -= 1
        
        when CONSTS["LEFT_CURLY"]
          if !t.scanOperand
            throw :gotoloop, true
          end
          # Object initialiser.  As for array initialisers (see above),
          # parse using recursive descent.
          x.curlyLevel += 1
          n = Node.new(t, CONSTS["OBJECT_INIT"])
  
  catch(:gotoobject_init) do
  #object_init:
          if !t.match(CONSTS["RIGHT_CURLY"])
            begin
              tt = t.get
              if (t.token.value == "get" or t.token.value == "set") and t.peek == CONSTS["IDENTIFIER"]
                raise SyntaxError.new("Illegal property accessor", t) if x.ecmaStrictMode
                n.push(function_definition(t, x, true, CONSTS["EXPRESSED_FORM"]))
              else
                case tt
                  when CONSTS["IDENTIFIER"], CONSTS["NUMBER"], CONSTS["STRING"]
                    id = Node.new(t)
                  
                  when CONSTS["RIGHT_CURLY"]
                    raise SyntaxError.new("Illegal trailing ,", t) if x.ecmaStrictMode
                    throw :gotoobject_init
                  
                  else
                    raise SyntaxError.new("Invalid property name", t)
                end
                t.mustMatch(CONSTS["COLON"])
                n2 = Node.new(t, CONSTS["PROPERTY_INIT"])
                n2.push(id)
                n2.push(expression(t, x, CONSTS["COMMA"]))
                n.push(n2)
              end
            end while t.match(CONSTS["COMMA"])
            t.mustMatch(CONSTS["RIGHT_CURLY"])
          end
          operands.push(n)
          t.scanOperand = false
          x.curlyLevel -= 1
  end
  
        when CONSTS["RIGHT_CURLY"]
          raise SyntaxError.new("PANIC: right curly botch", t) if !t.scanOperand and x.curlyLevel != cl
          throw :gotoloop, true
        
        when CONSTS["LEFT_PAREN"]
          if t.scanOperand
            operators.push(Node.new(t, CONSTS["GROUP"]))
          else
            reduce(operators, operands, t) while operators.length > 0 && OPPRECEDENCE[operators.last.type] && OPPRECEDENCE[operators.last.type] > OPPRECEDENCE[CONSTS["NEW"]]
            # Handle () now, to regularize the n-ary case for n > 0.
            # We must set scanOperand in case there are arguments and
            # the first one is a regexp or unary+/-.
            n = operators.last
            t.scanOperand = true
            if t.match(CONSTS["RIGHT_PAREN"])
              if n && n.type == CONSTS["NEW"]
                operators.pop
                n.push(operands.pop)
              else
                n = Node.new(t, CONSTS["CALL"])
                n.push(operands.pop)
                n.push(Node.new(t, CONSTS["LIST"]))
              end
              operands.push(n)
              t.scanOperand = false
              #puts "woah"
              break
            end
            if n && n.type == CONSTS["NEW"]
              n.type = CONSTS["NEW_WITH_ARGS"]
            else
              operators.push(Node.new(t, CONSTS["CALL"]))
            end
          end
          x.parenLevel += 1
          
        when CONSTS["RIGHT_PAREN"]
          if t.scanOperand or x.parenLevel == pl
            throw :gotoloop, true
          end
          while (tt = reduce(operators, operands, t).type) != CONSTS["GROUP"] \
              and tt != CONSTS["CALL"] and tt != CONSTS["NEW_WITH_ARGS"]
            nil
          end
          if tt != CONSTS["GROUP"]
            n = operands.last
            if n[1].type != CONSTS["COMMA"]
              n2 = n[1]
              n[1] = Node.new(t, CONSTS["LIST"])
              n[1].push(n2)
            else
              n[1].type = CONSTS["LIST"]
            end
          end
          x.parenLevel -= 1
          
        # Automatic semicolon insertion means we may scan across a newline
        # and into the beginning of another statement.  If so, break out of
        # the while loop and let the t.scanOperand logic handle errors.
        else
          throw :gotoloop, true
      end
    end
  
  end
  end
  
    raise SyntaxError.new("Missing : after ?", t) if x.hookLevel != hl
    raise SyntaxError.new("Missing operand", t) if t.scanOperand
      
    # Resume default mode, scanning for operands, not operators.
    t.scanOperand = true
    t.unget
    reduce(operators, operands, t) while operators.length > 0
    return operands.pop
  end

  def parse (source, line = 1)
    t = Tokenizer.new(source, line)
    x = CompilerContext.new(false)
    n = script(t, x)
    raise SyntaxError.new("Syntax error", t) if !t.done
      return n
  end

  def process(js)
    sexp = walk_tree(parse(js))
    if @class_cache.length > 0
      sexp[0] = *@class_cache.values
      sexp.unshift(:block)
    end
    sexp
  end

  def get_children(n)
    children = []
    attrs = [
      n.type, n.value, n.lineno, n.start, n.end, n.tokenizer, n.initializer,
      n.name, n.params, n.funDecls, n.varDecls, n.body, n.functionForm,
      n.assignOp, n.expression, n.condition, n.thenPart, n.elsePart,
      n.readOnly, n.isLoop, n.setup, n.postfix, n.update, n.exception,
      n.object, n.iterator, n.varDecl, n.label, n.target, n.tryBlock,
      n.catchClauses, n.varName, n.guard, n.block, n.discriminant, n.cases,
      n.defaultIndex, n.caseLabel, n.statements, n.statement]
    
    n.length.times do |i|
      children.push(n[i]) if n[i] != n and n[i].class == Node
    end
    
    attrs.length.times do |attr|
      children.push(attrs[attr]) if attrs[attr].class == Node and attrs[attr] != n
    end
    
    return children
  end

  def walk_tree(n)
    sexp = [TOKENS[n.type]]
    case TOKENS[n.type]
    when 'this'
      sexp = [:self]
    when 'SCRIPT'
      sexp = [:block]
    when 'function'
      sexp = [:block, [:args, *n.params.map { |x| x.to_sym } ]]
    when 'STRING'
      sexp = [:str, eval(n.value)]
    when 'LIST'
      sexp = [:array]
    when 'return', 'BLOCK', 'if'
      sexp = [TOKENS[n.type].downcase.to_sym]
    when 'NUMBER'
      sexp = [:lit, n.value]
    when 'IDENTIFIER'
      # Converting puts to alert
      #n.value = 'puts' if n.value == 'alert'
      if n.value =~ /^[A-Z]/
        sexp = [:const, (n.name || n.value).to_sym]
      else
        sexp = [:lvar, (n.name || n.value).to_sym]
      end
    end
    children = get_children(n)
    children.length.times do |i|
      sexp << walk_tree(children[i])
    end
    case TOKENS[n.type]
    when 'INDEX'
      sexp = :call, sexp[1], :[], [:array, sexp[2]]
    when '.'
      sexp = :call, sexp[1], sexp[2][1]
    when 'var'
      sexp[1][0] = :lasgn
      sexp = sexp[1]
    when 'new'
      name = sexp[1][1]
      if @function_cache[name] && ! @class_cache[name]
        func = @function_cache[name]
        @class_cache[name] =
          [:class, name.to_s.capitalize.intern, [:const, :OpenStruct],
          [:defn, 'initialize',[:scope, [:block, [:args], [:super], [:fcall, name]]]],
          func ]
        sexp[1][1] = sexp[1][1].to_s.capitalize.intern
        sexp = [:call, sexp[1], sexp[0].to_sym]
      else
        if sexp[1][1] == :Object
          sexp[1][1] = :OpenStruct
        end
        sexp = [:call, sexp[1], sexp[0].to_sym]
      end
    when 'CALL'
      if sexp[1][0] == :call
        params = sexp[2]
        sexp = sexp[1]
        sexp << params unless params.nil?
      else
        if sexp[1][0] == '.' # is this a method call?
          sexp = [:call, sexp[1][1], sexp[1][2][1]]
        else
          sexp = [:fcall, sexp[1][1], sexp[2]]
        end
      end
    when 'GROUP'
      sexp = sexp[1]
    when 'function'
      sexp = [:defn, n.name, [:scope, sexp]]
      @function_cache[sexp[1].to_sym] = sexp.dup unless sexp[1].nil?
    when '+', '-', '*', '/'
      sexp = :call, sexp[1], sexp[0].to_sym, sexp[2]
    when '='
      case n.value
      when '+'
        sexp = :lasgn, sexp[1][1], [:call, sexp[1], :+, [:array, sexp[2]]]
      when '-'
        sexp = :lasgn, sexp[1][1], [:call, sexp[1], :-, [:array, sexp[2]]]
      else
        # This might be an array index
        if sexp[1][0] == :call && sexp[1][2] == :[]
          sexp = :attrasgn, sexp[1][1], :[]=, [:array, sexp[1][3][1], sexp[2] ]
        elsif sexp[1][0] == :call && sexp[1][1] == [:self] && @function_cache[sexp[2][1]]
          scope = @function_cache[sexp[2][1]].dup
          scope[1] = sexp[1].last.to_s
          sexp = [:sclass, [:vcall, :self], scope]
        else
          if n.value == '='
            if sexp[1][0] == :call
              if sexp.last[0] == :defn && sexp.last[1].nil?
                function = sexp.last.dup
                function[1] = sexp[1].last
                sexp = [:sclass, sexp[1][1],
                          [:scope, function ]
                ]
              else
                sym = "#{sexp[1].last.to_s}=".to_sym
                sexp = [:attrasgn, sexp[1][1], sym, [:array, sexp.last]]
              end
            else
              sexp = [:lasgn, sexp[1][1], sexp[2]]
            end
          else
            sexp = :call, sexp[1], sexp[0].to_sym, [:array, sexp[2]]
          end
        end
      end
    when '<', '>', '>=', '<=', '=='
      sexp = :call, sexp[1], sexp[0].to_sym, [:array, sexp[2]]
    when '++'
      if n.postfix
        sexp = :call, [:array, sexp[1].dup, [:lasgn, sexp[1][1], [:call, sexp[1], :+, [:array, [:lit, 1]]]]], :first
      else
        sexp = [:lasgn, :i, [:call, [:lvar, :i], :+, [:array, [:lit, 1]]]]
      end
    when '--'
      if n.postfix
        sexp = :call, [:array, sexp[1], [:lasgn, sexp[1][1], [:call, sexp[1], :-, [:array, [:lit, 1]]]]], :first
      else
        sexp = [:lasgn, :i, [:call, [:lvar, :i], :-, [:array, [:lit, 1]]]]
      end
    when ';'
      sexp = sexp[1]
    when 'for'
      sexp = [:begin,
              [:block, sexp[3], [:while, sexp[2], sexp[1] << sexp[4], true]],
            ]
    end
    sexp
  end
end
