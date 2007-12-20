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
  | IDENT IDENT '(' ')' '{' FunctionBody '}'  { raise "Not implemented" }
  | IDENT IDENT '(' FormalParameterList ')' '{' FunctionBody '}' {
      raise "Not implemented"
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
    THIS          { raise "Not implemented" }
  | Literal
  | ArrayLiteral
  | IDENT         { result = ResolveNode.new(val.first) }
  | '(' Expr ')'  { raise "Not implemented" }
  ;

  ArrayLiteral:
    '[' ElisionOpt ']'                  { raise "Not implemented" }
  | '[' ElementList ']'                 { raise "Not implemented" }
  | '[' ElementList ',' ElisionOpt ']'  { raise "Not implemented" }
  ;

  ElementList:
    ElisionOpt AssignmentExpr { raise "Not implemented" }
  | ElementList ',' ElisionOpt AssignmentExpr { raise "Not implemented" }
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
  | MemberExprNoBF '[' Expr ']' { raise; result = BracketAccessorNode.new(val[0], val[2]) }
  | MemberExprNoBF '.' IDENT    { raise; result = DotAccessorNode.new(val[0], val[2]); }
  | NEW MemberExpr Arguments    { raise; result = NewExprNode.new(val[1], val[2]); }
  ;

  NewExpr:
    MemberExpr
  | NEW NewExpr { raise; result = NewExprNode.new(val[1]); }
  ;

  NewExprNoBF:
    MemberExprNoBF
  | NEW NewExpr { raise; result = NewExprNode.new(val[1]); }
  ;

  CallExpr:
    MemberExpr Arguments  { raise; result = makeFunctionCallNode($1, $2); }
  | CallExpr Arguments    { raise; result = makeFunctionCallNode($1, $2); }
  | CallExpr '[' Expr ']' { raise; result = BracketAccessorNode.new($1, $3); }
  | CallExpr '.' IDENT    { raise; result = DotAccessorNode.new($1, $3); }
  ;

  CallExprNoBF:
    MemberExprNoBF Arguments  { raise; result = makeFunctionCallNode($1, $2); }
  | CallExprNoBF Arguments    { raise; result = makeFunctionCallNode($1, $2); }
  | CallExprNoBF '[' Expr ']' { raise; result = BracketAccessorNode.new($1, $3); }
  | CallExprNoBF '.' IDENT    { raise; result = DotAccessorNode.new($1, $3); }
  ;

  Arguments:
    '(' ')'               { result = ArgumentsNode.new([]) }
  | '(' ArgumentList ')'  { raise; result = ArgumentsNode.new($2.head); }
  ;

  ArgumentList:
    AssignmentExpr                      { raise; result.head = ArgumentListNode.new($1);
                                          result.tail = result.head; }
  | ArgumentList ',' AssignmentExpr     { raise; result.head = $1.head;
                                          result.tail = ArgumentListNode.new($1.tail, $3); }
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
  | LeftHandSideExpr PLUSPLUS   { raise; result = makePostfixNode($1, OpPlusPlus); }
  | LeftHandSideExpr MINUSMINUS { raise; result = makePostfixNode($1, OpMinusMinus); }
  ;

  PostfixExprNoBF:
    LeftHandSideExprNoBF
  | LeftHandSideExprNoBF PLUSPLUS   { raise; result = makePostfixNode($1, OpPlusPlus); }
  | LeftHandSideExprNoBF MINUSMINUS { raise; result = makePostfixNode($1, OpMinusMinus); }
  ;

  UnaryExprCommon:
    DELETE UnaryExpr     { raise; result = makeDeleteNode($2); }
  | VOID UnaryExpr       { raise; result = VoidNode.new($2); }
  | TYPEOF UnaryExpr          { raise; result = makeTypeOfNode($2); }
  | PLUSPLUS UnaryExpr        { raise; result = makePrefixNode($2, OpPlusPlus); }
  | AUTOPLUSPLUS UnaryExpr    { raise; result = makePrefixNode($2, OpPlusPlus); }
  | MINUSMINUS UnaryExpr      { raise; result = makePrefixNode($2, OpMinusMinus); }
  | AUTOMINUSMINUS UnaryExpr  { raise; result = makePrefixNode($2, OpMinusMinus); }
  | '+' UnaryExpr             { raise; result = UnaryPlusNode.new($2); }
  | '-' UnaryExpr             { raise; result = makeNegateNode($2); }
  | '~' UnaryExpr             { raise; result = BitwiseNotNode.new($2); }
  | '!' UnaryExpr             { raise; result = LogicalNotNode.new($2); }
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
  | MultiplicativeExpr '*' UnaryExpr  { raise; result = MultNode.new($1, $3); }
  | MultiplicativeExpr '/' UnaryExpr  { raise; result = DivNode.new($1, $3); }
  | MultiplicativeExpr '%' UnaryExpr  { raise; result = ModNode.new($1, $3); }
  ;

  MultiplicativeExprNoBF:
    UnaryExprNoBF
  | MultiplicativeExprNoBF '*' UnaryExpr { raise; result = MultNode.new($1, $3); }
  | MultiplicativeExprNoBF '/' UnaryExpr { raise; result = DivNode.new($1, $3); }
  | MultiplicativeExprNoBF '%' UnaryExpr { raise; result = ModNode.new($1, $3); }
  ;

  AdditiveExpr:
    MultiplicativeExpr
  | AdditiveExpr '+' MultiplicativeExpr { raise; result = makeAddNode($1, $3); }
  | AdditiveExpr '-' MultiplicativeExpr { raise; result = SubNode.new($1, $3); }
  ;

  AdditiveExprNoBF:
    MultiplicativeExprNoBF
  | AdditiveExprNoBF '+' MultiplicativeExpr { raise; result = makeAddNode($1, $3); }
  | AdditiveExprNoBF '-' MultiplicativeExpr { raise; result = SubNode.new($1, $3); }
  ;

  ShiftExpr:
    AdditiveExpr
  | ShiftExpr LSHIFT AdditiveExpr   { raise; result = LeftShiftNode.new($1, $3); }
  | ShiftExpr RSHIFT AdditiveExpr   { raise; result = RightShiftNode.new($1, $3); }
  | ShiftExpr URSHIFT AdditiveExpr  { raise; result = UnsignedRightShiftNode.new($1, $3); }
  ;

  ShiftExprNoBF:
    AdditiveExprNoBF
  | ShiftExprNoBF LSHIFT AdditiveExpr   { raise; result = LeftShiftNode.new($1, $3); }
  | ShiftExprNoBF RSHIFT AdditiveExpr   { raise; result = RightShiftNode.new($1, $3); }
  | ShiftExprNoBF URSHIFT AdditiveExpr  { raise; result = UnsignedRightShiftNode.new($1, $3); }
  ;

  RelationalExpr:
    ShiftExpr
  | RelationalExpr '<' ShiftExpr        { raise; result = makeLessNode($1, $3); }
  | RelationalExpr '>' ShiftExpr        { raise; result = GreaterNode.new($1, $3); }
  | RelationalExpr LE ShiftExpr         { raise; result = LessEqNode.new($1, $3); }
  | RelationalExpr GE ShiftExpr         { raise; result = GreaterEqNode.new($1, $3); }
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
  | RelationalExprNoBF '<' ShiftExpr    { raise; result = makeLessNode($1, $3); }
  | RelationalExprNoBF '>' ShiftExpr    { raise; result = GreaterNode.new($1, $3); }
  | RelationalExprNoBF LE ShiftExpr     { raise; result = LessEqNode.new($1, $3); }
  | RelationalExprNoBF GE ShiftExpr     { raise; result = GreaterEqNode.new($1, $3); }
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
  | LeftHandSideExpr AssignmentOperator AssignmentExpr
                                        { raise; result = makeAssignNode($1, $2, $3); }
  ;

  AssignmentExprNoIn:
    ConditionalExprNoIn
  | LeftHandSideExpr AssignmentOperator AssignmentExprNoIn
                                        { raise; result = makeAssignNode($1, $2, $3); }
  ;

  AssignmentExprNoBF:
    ConditionalExprNoBF
  | LeftHandSideExprNoBF AssignmentOperator AssignmentExpr
                                        { raise; result = makeAssignNode($1, $2, $3); }
  ;

  AssignmentOperator:
    '='                                 { raise; result = OpEqual; }
  | PLUSEQUAL                           { raise; result = OpPlusEq; }
  | MINUSEQUAL                          { raise; result = OpMinusEq; }
  | MULTEQUAL                           { raise; result = OpMultEq; }
  | DIVEQUAL                            { raise; result = OpDivEq; }
  | LSHIFTEQUAL                         { raise; result = OpLShift; }
  | RSHIFTEQUAL                         { raise; result = OpRShift; }
  | URSHIFTEQUAL                        { raise; result = OpURShift; }
  | ANDEQUAL                            { raise; result = OpAndEq; }
  | XOREQUAL                            { raise; result = OpXOrEq; }
  | OREQUAL                             { raise; result = OpOrEq; }
  | MODEQUAL                            { raise; result = OpModEq; }
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
  | ExprNoBF ',' AssignmentExpr         { raise; result = CommaNode.new($1, $3); }
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
      yyabort unless allow_auto_semi?(val.last)
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
      raise
      result = ExprStatementNode.new($1)
      debug(result)
    }
  | ExprNoBF error {
      raise
      result = ExprStatementNode.new($1)
      debug(result)
      #AUTO_SEMICOLON
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

  def debug(*args)
    logger.debug(*args) if @logger
  end
