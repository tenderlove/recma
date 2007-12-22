/* vim: set filetype=racc : */

class RKelly::GeneratedParser

/* Literals */
token NULL TRUE FALSE

/* keywords */
token BREAK CASE CATCH CONST CONTINUE DEBUGGER DEFAULT DELETE DO ELSE ENUM
token FINALLY FOR FUNCTION IF IN INSTANCEOF NEW RETURN SWITCH THIS THROW TRY
token TYPEOF VAR VOID WHILE WITH

/* punctuators */
token EQEQ NE                     /* == and != */
token STREQ STRNEQ                /* === and !== */
token LE GE                       /* < and > */
token OR AND                      /* || and && */
token PLUSPLUS MINUSMINUS         /* ++ and --  */
token LSHIFT                      /* << */
token RSHIFT URSHIFT              /* >> and >>> */
token PLUSEQUAL MINUSEQUAL        /* += and -= */
token MULTEQUAL DIVEQUAL          /* *= and /= */
token LSHIFTEQUAL                 /* <<= */
token RSHIFTEQUAL URSHIFTEQUAL    /* >>= and >>>= */
token ANDEQUAL MODEQUAL           /* &= and %= */
token XOREQUAL OREQUAL            /* ^= and |= */

/* Terminal types */
token REGEXP
token NUMBER
token STRING
token IDENT

token AUTOPLUSPLUS AUTOMINUSMINUS IF_WITHOUT_ELSE

prechigh
  nonassoc IF_WITHOUT_ELSE
  nonassoc ELSE
preclow

rule
  SourceElements:
    SourceElement
  | SourceElements SourceElement        { result = val.flatten }
  ;

  SourceElement:
    FunctionDeclaration
  | Statement
  ;

  Statement:
    Block
  | VariableStatement
  | ConstStatement
  | EmptyStatement
  | ExprStatement
  | IfStatement
  | IterationStatement
  | ContinueStatement
  | BreakStatement
  | ReturnStatement
  | WithStatement
  | SwitchStatement
  | LabelledStatement
  | ThrowStatement
  | TryStatement
  | DebuggerStatement
  ;

  Literal:
    NULL    { result = NullNode.new(val.first) }
  | TRUE    { result = TrueNode.new(val.first) }
  | FALSE   { result = FalseNode.new(val.first) }
  | NUMBER  { result = NumberNode.new(val.first) }
  | STRING  { result = StringNode.new(val.first) }
  | REGEXP  { result = RegexpNode.new(val.first) }
  ;

  Property:
    IDENT ':' AssignmentExpr {
      result = PropertyNode.new(val[0], val[2])
    }
  | STRING ':' AssignmentExpr { result = PropertyNode.new(val.first, val.last) }
  | NUMBER ':' AssignmentExpr { result = PropertyNode.new(val.first, val.last) }
  | IDENT IDENT '(' ')' '{' FunctionBody '}'  {
      klass = property_class_for(val.first)
      yyabort unless klass
      result = klass.new(val[1], FunctionExprNode.new(nil, val[5]))
    }
  | IDENT IDENT '(' FormalParameterList ')' '{' FunctionBody '}' {
      klass = property_class_for(val.first)
      yyabort unless klass
      result = klass.new(val[1], FunctionExprNode.new(nil, val[6], val[3]))
    }
  ;

  PropertyList:
    Property                    { result = val }
  | PropertyList ',' Property   { result = [val.first, val.last].flatten }
  ;

  PrimaryExpr:
    PrimaryExprNoBrace
  | '{' '}'                   { result = ObjectLiteralNode.new([]) }
  | '{' PropertyList '}'      { result = ObjectLiteralNode.new(val[1]) }
  | '{' PropertyList ',' '}'  { result = ObjectLiteralNode.new(val[1]) }
  ;

  PrimaryExprNoBrace:
    THIS          { result = ThisNode.new(val.first) }
  | Literal
  | ArrayLiteral
  | IDENT         { result = ResolveNode.new(val.first) }
  | '(' Expr ')'  { result = val[1] }
  ;

  ArrayLiteral:
    '[' ElisionOpt ']'           { result = ArrayNode.new([] + [nil] * val[1]) }
  | '[' ElementList ']'                 { result = ArrayNode.new(val[1]) }
  | '[' ElementList ',' ElisionOpt ']'  {
      result = ArrayNode.new(val[1] + [nil] * val[3])
    }
  ;

  ElementList:
    ElisionOpt AssignmentExpr {
      result = [nil] * val[0] + [ElementNode.new(val[1])]
    }
  | ElementList ',' ElisionOpt AssignmentExpr {
      result = [val[0], [nil] * val[2], ElementNode.new(val[3])].flatten
    }
  ;

  ElisionOpt:
    /* nothing */ { result = 0 }
  | Elision
  ;

  Elision:
    ',' { result = 1 }
  | Elision ',' { result = val.first + 1 }
  ;

  MemberExpr:
    PrimaryExpr
  | FunctionExpr
  | MemberExpr '[' Expr ']' { result = BracketAccessorNode.new(val[0], val[2]) }
  | MemberExpr '.' IDENT    { result = DotAccessorNode.new(val[0], val[2]) }
  | NEW MemberExpr Arguments { result = NewExprNode.new(val[1], val[2]) }
  ;

  MemberExprNoBF:
    PrimaryExprNoBrace
  | MemberExprNoBF '[' Expr ']' {
      result = BracketAccessorNode.new(val[0], val[2])
    }
  | MemberExprNoBF '.' IDENT    { result = DotAccessorNode.new(val[0], val[2]) }
  | NEW MemberExpr Arguments    { result = NewExprNode.new(val[1], val[2]) }
  ;

  NewExpr:
    MemberExpr
  | NEW NewExpr { result = NewExprNode.new(val[1], ArgumentsNode.new([])) }
  ;

  NewExprNoBF:
    MemberExprNoBF
  | NEW NewExpr { result = NewExprNode.new(val[1], ArgumentsNode.new([])) }
  ;

  CallExpr:
    MemberExpr Arguments  { result = FunctionCallNode.new(val[0], val[1]) }
  | CallExpr Arguments    { result = FunctionCallNode.new(val[0], val[1]) }
  | CallExpr '[' Expr ']' { result = BracketAccessorNode.new(val[0], val[2]) }
  | CallExpr '.' IDENT    { result = DotAccessorNode.new(val[0], val[2]) }
  ;

  CallExprNoBF:
    MemberExprNoBF Arguments  { result = FunctionCallNode.new(val[0], val[1]) }
  | CallExprNoBF Arguments    { result = FunctionCallNode.new(val[0], val[1]) }
  | CallExprNoBF '[' Expr ']' { result = BracketAccessorNode.new(val[0], val[2]) }
  | CallExprNoBF '.' IDENT    { result = DotAccessorNode.new(val[0], val[2]) }
  ;

  Arguments:
    '(' ')'               { result = ArgumentsNode.new([]) }
  | '(' ArgumentList ')'  { result = ArgumentsNode.new(val[1]); }
  ;

  ArgumentList:
    AssignmentExpr                      { result = val }
  | ArgumentList ',' AssignmentExpr     { result = [val[0], val[2]].flatten }
  ;

  LeftHandSideExpr:
    NewExpr
  | CallExpr
  ;

  LeftHandSideExprNoBF:
    NewExprNoBF
  | CallExprNoBF
  ;

  PostfixExpr:
    LeftHandSideExpr
  | LeftHandSideExpr PLUSPLUS   { result = PostfixNode.new(val[0], '++') }
  | LeftHandSideExpr MINUSMINUS { result = PostfixNode.new(val[0], '--') }
  ;

  PostfixExprNoBF:
    LeftHandSideExprNoBF
  | LeftHandSideExprNoBF PLUSPLUS   { result = PostfixNode.new(val[0], '++') }
  | LeftHandSideExprNoBF MINUSMINUS { result = PostfixNode.new(val[0], '--') }
  ;

  UnaryExprCommon:
    DELETE UnaryExpr     { result = DeleteNode.new(val[1]) }
  | VOID UnaryExpr       { result = VoidNode.new(val[1]) }
  | TYPEOF UnaryExpr          { result = TypeOfNode.new(val[1]) }
  | PLUSPLUS UnaryExpr        { result = PrefixNode.new(val[1], '++') }
  /* FIXME: Not sure when this can ever happen
  | AUTOPLUSPLUS UnaryExpr    { result = makePrefixNode($2, OpPlusPlus); } */
  | MINUSMINUS UnaryExpr      { result = PrefixNode.new(val[1], '--') }
  /* FIXME: Not sure when this can ever happen
  | AUTOMINUSMINUS UnaryExpr  { result = makePrefixNode($2, OpMinusMinus); } */
  | '+' UnaryExpr             { result = UnaryPlusNode.new(val[1]) }
  | '-' UnaryExpr             { result = UnaryMinusNode.new(val[1]) }
  | '~' UnaryExpr             { result = BitwiseNotNode.new(val[1]) }
  | '!' UnaryExpr             { result = LogicalNotNode.new(val[1]) }
  ;

  UnaryExpr:
    PostfixExpr
  | UnaryExprCommon
  ;

  UnaryExprNoBF:
    PostfixExprNoBF
  | UnaryExprCommon
  ;

  MultiplicativeExpr:
    UnaryExpr
  | MultiplicativeExpr '*' UnaryExpr { result = MultiplyNode.new(val[0],val[2])}
  | MultiplicativeExpr '/' UnaryExpr { result = DivideNode.new(val[0], val[2]) }
  | MultiplicativeExpr '%' UnaryExpr { result = ModulusNode.new(val[0], val[2])}
  ;

  MultiplicativeExprNoBF:
    UnaryExprNoBF
  | MultiplicativeExprNoBF '*' UnaryExpr { result = MultiplyNode.new(val[0], val[2]) }
  | MultiplicativeExprNoBF '/' UnaryExpr { result = DivideNode.new(val[0],val[2]) }
  | MultiplicativeExprNoBF '%' UnaryExpr { result = ModulusNode.new(val[0], val[2]) }
  ;

  AdditiveExpr:
    MultiplicativeExpr
  | AdditiveExpr '+' MultiplicativeExpr { result = AddNode.new(val[0], val[2]) }
  | AdditiveExpr '-' MultiplicativeExpr { result = SubtractNode.new(val[0], val[2]) }
  ;

  AdditiveExprNoBF:
    MultiplicativeExprNoBF
  | AdditiveExprNoBF '+' MultiplicativeExpr { result = AddNode.new(val[0], val[2]) }
  | AdditiveExprNoBF '-' MultiplicativeExpr { result = SubtractNode.new(val[0], val[2]) }
  ;

  ShiftExpr:
    AdditiveExpr
  | ShiftExpr LSHIFT AdditiveExpr   { result = LeftShiftNode.new(val[0], val[2]) }
  | ShiftExpr RSHIFT AdditiveExpr   { result = RightShiftNode.new(val[0], val[2]) }
  | ShiftExpr URSHIFT AdditiveExpr  { result = UnsignedRightShiftNode.new(val[0], val[2]) }
  ;

  ShiftExprNoBF:
    AdditiveExprNoBF
  | ShiftExprNoBF LSHIFT AdditiveExpr   { result = LeftShiftNode.new(val[0], val[2]) }
  | ShiftExprNoBF RSHIFT AdditiveExpr   { result = RightShiftNode.new(val[0], val[2]) }
  | ShiftExprNoBF URSHIFT AdditiveExpr  { result = UnsignedRightShiftNode.new(val[0], val[2]) }
  ;

  RelationalExpr:
    ShiftExpr
  | RelationalExpr '<' ShiftExpr        { result = LessNode.new(val[0], val[2])}
  | RelationalExpr '>' ShiftExpr        { result = GreaterNode.new(val[0], val[2]) }
  | RelationalExpr LE ShiftExpr         { result = LessOrEqualNode.new(val[0], val[2]) }
  | RelationalExpr GE ShiftExpr         { result = GreaterOrEqualNode.new(val[0], val[2]) }
  | RelationalExpr INSTANCEOF ShiftExpr { raise; result = InstanceOfNode.new($1, $3); }
  | RelationalExpr IN ShiftExpr    { raise; result = InNode.new($1, $3); }
  ;

  RelationalExprNoIn:
    ShiftExpr
  | RelationalExprNoIn '<' ShiftExpr    { raise; result = makeLessNode($1, $3); }
  | RelationalExprNoIn '>' ShiftExpr    { raise; result = GreaterNode.new($1, $3); }
  | RelationalExprNoIn LE ShiftExpr     { raise; result = LessEqNode.new($1, $3); }
  | RelationalExprNoIn GE ShiftExpr     { raise; result = GreaterEqNode.new($1, $3); }
  | RelationalExprNoIn INSTANCEOF ShiftExpr
                                        { raise; result = InstanceOfNode.new($1, $3); }
  ;

  RelationalExprNoBF:
    ShiftExprNoBF
  | RelationalExprNoBF '<' ShiftExpr    { result = LessNode.new(val[0], val[2]) }
  | RelationalExprNoBF '>' ShiftExpr    { result = GreaterNode.new(val[0], val[2]) }
  | RelationalExprNoBF LE ShiftExpr     { result = LessOrEqualNode.new(val[0], val[2]) }
  | RelationalExprNoBF GE ShiftExpr     { result = GreaterOrEqualNode.new(val[0], val[2]) }
  | RelationalExprNoBF INSTANCEOF ShiftExpr
                                        { raise; result = InstanceOfNode.new($1, $3); }
  | RelationalExprNoBF IN ShiftExpr     { raise; result = InNode.new($1, $3); }
  ;

  EqualityExpr:
    RelationalExpr
  | EqualityExpr EQEQ RelationalExpr    { raise; result = EqualNode.new($1, $3); }
  | EqualityExpr NE RelationalExpr      { raise; result = NotEqualNode.new($1, $3); }
  | EqualityExpr STREQ RelationalExpr   { raise; result = StrictEqualNode.new($1, $3); }
  | EqualityExpr STRNEQ RelationalExpr  { raise; result = NotStrictEqualNode.new($1, $3); }
  ;

  EqualityExprNoIn:
    RelationalExprNoIn
  | EqualityExprNoIn EQEQ RelationalExprNoIn
                                        { raise; result = EqualNode.new($1, $3); }
  | EqualityExprNoIn NE RelationalExprNoIn
                                        { raise; result = NotEqualNode.new($1, $3); }
  | EqualityExprNoIn STREQ RelationalExprNoIn
                                        { raise; result = StrictEqualNode.new($1, $3); }
  | EqualityExprNoIn STRNEQ RelationalExprNoIn
                                        { raise; result = NotStrictEqualNode.new($1, $3); }
  ;

  EqualityExprNoBF:
    RelationalExprNoBF
  | EqualityExprNoBF EQEQ RelationalExpr
                                        { raise; result = EqualNode.new($1, $3); }
  | EqualityExprNoBF NE RelationalExpr  { raise; result = NotEqualNode.new($1, $3); }
  | EqualityExprNoBF STREQ RelationalExpr
                                        { raise; result = StrictEqualNode.new($1, $3); }
  | EqualityExprNoBF STRNEQ RelationalExpr
                                        { raise; result = NotStrictEqualNode.new($1, $3); }
  ;

  BitwiseANDExpr:
    EqualityExpr
  | BitwiseANDExpr '&' EqualityExpr     { raise; result = BitAndNode.new($1, $3); }
  ;

  BitwiseANDExprNoIn:
    EqualityExprNoIn
  | BitwiseANDExprNoIn '&' EqualityExprNoIn
                                        { raise; result = BitAndNode.new($1, $3); }
  ;

  BitwiseANDExprNoBF:
    EqualityExprNoBF
  | BitwiseANDExprNoBF '&' EqualityExpr { raise; result = BitAndNode.new($1, $3); }
  ;

  BitwiseXORExpr:
    BitwiseANDExpr
  | BitwiseXORExpr '^' BitwiseANDExpr   { raise; result = BitXOrNode.new($1, $3); }
  ;

  BitwiseXORExprNoIn:
    BitwiseANDExprNoIn
  | BitwiseXORExprNoIn '^' BitwiseANDExprNoIn
                                        { raise; result = BitXOrNode.new($1, $3); }
  ;

  BitwiseXORExprNoBF:
    BitwiseANDExprNoBF
  | BitwiseXORExprNoBF '^' BitwiseANDExpr
                                        { raise; result = BitXOrNode.new($1, $3); }
  ;

  BitwiseORExpr:
    BitwiseXORExpr
  | BitwiseORExpr '|' BitwiseXORExpr    { raise; result = BitOrNode.new($1, $3); }
  ;

  BitwiseORExprNoIn:
    BitwiseXORExprNoIn
  | BitwiseORExprNoIn '|' BitwiseXORExprNoIn
                                        { raise; result = BitOrNode.new($1, $3); }
  ;

  BitwiseORExprNoBF:
    BitwiseXORExprNoBF
  | BitwiseORExprNoBF '|' BitwiseXORExpr
                                        { raise; result = BitOrNode.new($1, $3); }
  ;

  LogicalANDExpr:
    BitwiseORExpr
  | LogicalANDExpr AND BitwiseORExpr    { raise; result = LogicalAndNode.new($1, $3); }
  ;

  LogicalANDExprNoIn:
    BitwiseORExprNoIn
  | LogicalANDExprNoIn AND BitwiseORExprNoIn
                                        { raise; result = LogicalAndNode.new($1, $3); }
  ;

  LogicalANDExprNoBF:
    BitwiseORExprNoBF
  | LogicalANDExprNoBF AND BitwiseORExpr
                                        { raise; result = LogicalAndNode.new($1, $3); }
  ;

  LogicalORExpr:
    LogicalANDExpr
  | LogicalORExpr OR LogicalANDExpr     { raise; result = LogicalOrNode.new($1, $3); }
  ;

  LogicalORExprNoIn:
    LogicalANDExprNoIn
  | LogicalORExprNoIn OR LogicalANDExprNoIn
                                        { raise; result = LogicalOrNode.new($1, $3); }
  ;

  LogicalORExprNoBF:
    LogicalANDExprNoBF
  | LogicalORExprNoBF OR LogicalANDExpr { raise; result = LogicalOrNode.new($1, $3); }
  ;

  ConditionalExpr:
    LogicalORExpr
  | LogicalORExpr '?' AssignmentExpr ':' AssignmentExpr
                                        { raise; result = ConditionalNode.new($1, $3, $5); }
  ;

  ConditionalExprNoIn:
    LogicalORExprNoIn
  | LogicalORExprNoIn '?' AssignmentExprNoIn ':' AssignmentExprNoIn
                                        { raise; result = ConditionalNode.new($1, $3, $5); }
  ;

  ConditionalExprNoBF:
    LogicalORExprNoBF
  | LogicalORExprNoBF '?' AssignmentExpr ':' AssignmentExpr
                                        { raise; result = ConditionalNode.new($1, $3, $5); }
  ;

  AssignmentExpr:
    ConditionalExpr
  | LeftHandSideExpr AssignmentOperator AssignmentExpr {
      result = val[1].new(val.first, val.last)
    }
  ;

  AssignmentExprNoIn:
    ConditionalExprNoIn
  | LeftHandSideExpr AssignmentOperator AssignmentExprNoIn
                                        { raise; result = makeAssignNode($1, $2, $3); }
  ;

  AssignmentExprNoBF:
    ConditionalExprNoBF
  | LeftHandSideExprNoBF AssignmentOperator AssignmentExpr {
      result = val[1].new(val.first, val.last)
    }
  ;

  AssignmentOperator:
    '='                                 { result = OpEqualNode }
  | PLUSEQUAL                           { result = OpPlusEqualNode }
  | MINUSEQUAL                          { result = OpMinusEqualNode }
  | MULTEQUAL                           { result = OpMultiplyEqualNode }
  | DIVEQUAL                            { result = OpDivideEqualNode }
  | LSHIFTEQUAL                         { result = OpLShiftEqualNode }
  | RSHIFTEQUAL                         { result = OpRShiftEqualNode }
  | URSHIFTEQUAL                        { result = OpURShiftEqualNode }
  | ANDEQUAL                            { result = OpAndEqualNode }
  | XOREQUAL                            { result = OpXOrEqualNode }
  | OREQUAL                             { result = OpOrEqualNode }
  | MODEQUAL                            { result = OpModEqualNode }
  ;

  Expr:
    AssignmentExpr
  | Expr ',' AssignmentExpr             { raise; result = CommaNode.new($1, $3); }
  ;

  ExprNoIn:
    AssignmentExprNoIn
  | ExprNoIn ',' AssignmentExprNoIn     { raise; result = CommaNode.new($1, $3); }
  ;

  ExprNoBF:
    AssignmentExprNoBF
  | ExprNoBF ',' AssignmentExpr       { result = CommaNode.new(val[0], val[2]) }
  ;


  Block:
    '{' '}' {
      raise
      result = BlockNode.new(SourceElements.new)
      debug(result)
    }
  | '{' SourceElements '}' {
      raise
      result = BlockNode.new($2.release())
      debug(result)
    }
  ;

  VariableStatement:
    VAR VariableDeclarationList ';' {
      result = VarStatementNode.new(val[1])
      debug(result)
    }
  | VAR VariableDeclarationList error {
      result = VarStatementNode.new(val[1])
      debug(result)
      raise "no auto semi!" unless allow_auto_semi?(val.last)
    }
  ;

  VariableDeclarationList:
    VariableDeclaration                 { result = val }
  | VariableDeclarationList ',' VariableDeclaration {
      result = [val.first, val.last].flatten
    }
  ;

  VariableDeclarationListNoIn:
    VariableDeclarationNoIn             { raise; result.head = $1; 
                                          result.tail = result.head; }
  | VariableDeclarationListNoIn ',' VariableDeclarationNoIn
                                        { raise; result.head = $1.head;
                                          $1.tail.next = $3;
                                          result.tail = $3; }
  ;

  VariableDeclaration:
    IDENT             { result = VarDeclNode.new(val.first, nil) }
  | IDENT Initializer { result = VarDeclNode.new(val.first, val[1]) }
  ;

  VariableDeclarationNoIn:
    IDENT                               { raise; result = VarDeclNode.new($1, 0, VarDeclNode::Variable); }
  | IDENT InitializerNoIn               { raise; result = VarDeclNode.new($1, $2, VarDeclNode::Variable); }
  ;

  ConstStatement:
    CONST ConstDeclarationList ';' {
      result = ConstStatementNode.new(val[1])
      debug(result)
    }
  | CONST ConstDeclarationList error {
      result = ConstStatementNode.new(val[1])
      debug(result)
      yyerror unless allow_auto_semi?(val.last)
    }
  ;

  ConstDeclarationList:
    ConstDeclaration                    { result = val }
  | ConstDeclarationList ',' ConstDeclaration {
      result = [val.first, val.last].flatten
    }
  ;

  ConstDeclaration:
    IDENT             { result = VarDeclNode.new(val[0], nil, true) }
  | IDENT Initializer { result = VarDeclNode.new(val[0], val[1], true) }
  ;

  Initializer:
    '=' AssignmentExpr                  { result = AssignExprNode.new(val[1]) }
  ;

  InitializerNoIn:
    '=' AssignmentExprNoIn              { raise; result = AssignExprNode.new($2); }
  ;

  EmptyStatement:
    ';' { result = EmptyStatementNode.new(val[0]) }
  ;

  ExprStatement:
    ExprNoBF ';' {
      result = ExpressionStatementNode.new(val.first)
      debug(result)
    }
  | ExprNoBF error {
      result = ExpressionStatementNode.new(val.first)
      debug(result)
      yyabort unless allow_auto_semi?(val.last)
    }
  ;

  IfStatement:
    IF '(' Expr ')' Statement {
      raise
      result = IfNode.new($3, $5, 0)
      debug(result)
    } =IF_WITHOUT_ELSE
  | IF '(' Expr ')' Statement ELSE Statement {
      raise
      result = IfNode.new($3, $5, $7)
      debug(result)
    }
  ;

  IterationStatement:
    DO Statement WHILE '(' Expr ')' ';' {
      raise
      result = DoWhileNode.new($2, $5)
      debug(result)
    }
  | DO Statement WHILE '(' Expr ')' error {
      raise
      result = DoWhileNode.new($2, $5)
      debug(result)
    } /* Always performs automatic semicolon insertion. */
  | WHILE '(' Expr ')' Statement {
      raise
      result = WhileNode.new($3, $5)
      debug(result)
    }
  | FOR '(' ExprNoInOpt ';' ExprOpt ';' ExprOpt ')' Statement {
      raise
      result = ForNode.new($3, $5, $7, $9)
      debug(result)
    }
  | FOR '(' VAR VariableDeclarationListNoIn ';' ExprOpt ';' ExprOpt ')' Statement
    {
      raise
      result = ForNode.new($4.head, $6, $8, $10)
      debug(result)
    }
  | FOR '(' LeftHandSideExpr IN Expr ')' Statement
                                        {
                                            n = $3;
                                            yyabort if (!n.isLocation())
                                            result = ForInNode.new(n, $5, $7);
                                            debug(result);
                                        }
  | FOR '(' VAR IDENT IN Expr ')' Statement {
      raise
      result = ForInNode.new($4, 0, $6, $8)
      debug(result)
    }
  | FOR '(' VAR IDENT InitializerNoIn IN Expr ')' Statement {
      raise
      result = ForInNode.new($4, $5, $7, $9)
      debug(result)
    }
  ;

  ExprOpt:
    /* nothing */                       { raise; result = 0; }
  | Expr
  ;

  ExprNoInOpt:
    /* nothing */                       { raise; result = 0; }
  | ExprNoIn
  ;

  ContinueStatement:
    CONTINUE ';' {
      result = ContinueNode.new(nil)
      debug(result)
    }
  | CONTINUE error {
      result = ContinueNode.new(nil)
      debug(result)
      yyabort unless allow_auto_semi?(val[1])
    }
  | CONTINUE IDENT ';' {
      result = ContinueNode.new(val[1])
      debug(result)
    }
  | CONTINUE IDENT error {
      result = ContinueNode.new(val[1])
      debug(result)
      yyabort unless allow_auto_semi?(val[2])
    }
  ;

  BreakStatement:
    BREAK ';' {
      result = BreakNode.new(nil)
      debug(result)
    }
  | BREAK error {
      result = BreakNode.new(nil)
      debug(result)
      yyabort unless allow_auto_semi?(val[1])
    }
  | BREAK IDENT ';' {
      result = BreakNode.new(val[1])
      debug(result)
    }
  | BREAK IDENT error {
      result = BreakNode.new(val[1])
      debug(result)
      yyabort unless allow_auto_semi?(val[2])
    }
  ;

  ReturnStatement:
    RETURN ';' {
      result = ReturnNode.new(nil)
      debug(result)
    }
  | RETURN error {
      result = ReturnNode.new(nil)
      debug(result)
      yyabort unless allow_auto_semi?(val[1])
    }
  | RETURN Expr ';' {
      result = ReturnNode.new(val[1])
      debug(result)
    }
  | RETURN Expr error {
      result = ReturnNode.new(val[1])
      debug(result)
      yyabort unless allow_auto_semi?(val[2])
    }
  ;

  WithStatement:
    WITH '(' Expr ')' Statement {
      raise
      result = WithNode.new($3, $5)
      debug(result)
    }
  ;

  SwitchStatement:
    SWITCH '(' Expr ')' CaseBlock {
      raise
      result = SwitchNode.new($3, $5)
      debug(result)
    }
  ;

  CaseBlock:
    '{' CaseClausesOpt '}'              { raise; result = CaseBlockNode.new($2.head, 0, 0); }
  | '{' CaseClausesOpt DefaultClause CaseClausesOpt '}'
                                        { raise; result = CaseBlockNode.new($2.head, $3, $4.head); }
  ;

  CaseClausesOpt:
    /* nothing */                       { raise; result.head = 0; result.tail = 0; }
  | CaseClauses
  ;

  CaseClauses:
    CaseClause                          { raise; result.head = ClauseListNode.new($1);
                                          result.tail = result.head; }
  | CaseClauses CaseClause              { raise; result.head = $1.head; 
                                          result.tail = ClauseListNode.new($1.tail, $2); }
  ;

  CaseClause:
    CASE Expr ':'                       { raise; result = CaseClauseNode.new($2); }
  | CASE Expr ':' SourceElements        { raise; result = CaseClauseNode.new($2, $4.release()); }
  ;

  DefaultClause:
    DEFAULT ':'                         { raise; result = CaseClauseNode.new(0); }
  | DEFAULT ':' SourceElements          { raise; result = CaseClauseNode.new(0, $3.release()); }
  ;

  LabelledStatement:
    IDENT ':' Statement { result = LabelNode.new(val[0], val[2]) }
  ;

  ThrowStatement:
    THROW Expr ';' {
      result = ThrowNode.new(val[1])
      debug(result)
    }
  | THROW Expr error {
      result = ThrowNode.new(val[1])
      debug(result)
      yyabort unless allow_auto_semi?(val[2])
    }
  ;

  TryStatement:
    TRY Block FINALLY Block {
      raise
      result = TryNode.new($2, CommonIdentifiers::shared().nullIdentifier, 0, $4)
      debug(result)
    }
  | TRY Block CATCH '(' IDENT ')' Block {
      raise
      result = TryNode.new($2, $5, $7, 0)
      debug(result)
    }
  | TRY Block CATCH '(' IDENT ')' Block FINALLY Block {
      raise
      result = TryNode.new($2, $5, $7, $9)
      debug(result)
    }
  ;

  DebuggerStatement:
    DEBUGGER ';' {
      result = EmptyStatementNode.new(val[0])
      debug(result)
    }
  | DEBUGGER error {
      result = EmptyStatementNode.new(val[0])
      debug(result)
      yyabort unless allow_auto_semi?(val[1])
    }
  ;

  FunctionDeclaration:
    FUNCTION IDENT '(' ')' '{' FunctionBody '}' {
      result = FunctionDeclNode.new(val[1], val[5])
      debug(val[5])
    }
  | FUNCTION IDENT '(' FormalParameterList ')' '{' FunctionBody '}' {
      result = FunctionDeclNode.new(val[1], val[6], val[3])
      debug(val[6])
    }
  ;

  FunctionExpr:
    FUNCTION '(' ')' '{' FunctionBody '}' {
      result = FunctionExprNode.new(nil, val[4])
      debug(val[4])
    }
  | FUNCTION '(' FormalParameterList ')' '{' FunctionBody '}' {
      result = FunctionExprNode.new(nil, val[5], val[2])
      debug(val[5])
    }
  | FUNCTION IDENT '(' ')' '{' FunctionBody '}' {
      result = FunctionExprNode.new(val[1], val[5])
      debug(val[5])
    }
  | FUNCTION IDENT '(' FormalParameterList ')' '{' FunctionBody '}' {
      result = FunctionExprNode.new(val[1], val[6], val[3])
      debug(val[6])
    }
  ;

  FormalParameterList:
    IDENT                               { result = [ParameterNode.new(val[0])] }
  | FormalParameterList ',' IDENT       {
      result = [val.first, ParameterNode.new(val.last)].flatten
    }
  ;

  FunctionBody:
    /* not in spec */           { result = FunctionBodyNode.new(SourceElements.new([])) }
  | SourceElements              { result = FunctionBodyNode.new(val[0]) }
  ;
end

---- header
  require "rkelly/nodes"

---- inner
  include RKelly::Nodes

  def allow_auto_semi?(error_token)
    error_token == false || error_token == '}'
  end

  def property_class_for(ident)
    case ident
    when 'get'
      GetterPropertyNode
    when 'set'
      SetterPropertyNode
    end
  end

  def debug(*args)
    logger.debug(*args) if @logger
  end
