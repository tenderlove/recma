/* vim: set filetype=racc : */

class RKelly::Parser

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
    IDENT ':' AssignmentExpr                  { raise "Not implemented" }
  | STRING ':' AssignmentExpr                 { raise "Not implemented" }
  | NUMBER ':' AssignmentExpr                 { raise "Not implemented" }
  | IDENT IDENT '(' ')' '{' FunctionBody '}'  { raise "Not implemented" }
  | IDENT IDENT '(' FormalParameterList ')' '{' FunctionBody '}' {
      raise "Not implemented"
    }
  ;

  PropertyList:
    Property                    { raise "Not implemented" }
  | PropertyList ',' Property   { raise "Not implemented" }
  ;

  PrimaryExpr:
    PrimaryExprNoBrace
  | '{' '}'                   { raise "Not implemented" }
  | '{' PropertyList '}'      { raise "Not implemented" }
  | '{' PropertyList ',' '}'  { raise "Not implemented" }
  ;

  PrimaryExprNoBrace:
    THIS          { raise "Not implemented" }
  | Literal
  | ArrayLiteral
  | IDENT         { raise "Not implemented" }
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
  | MemberExpr '[' Expr ']' { raise "Not implemented" }
  | MemberExpr '.' IDENT    { raise "Not implemented" }
  | NEW MemberExpr Arguments { raise "Not implemented" }
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
  | CallExpr '.' IDENT    { raise; result = DotAccessorNode.new($1, *$3); }
  ;

  CallExprNoBF:
    MemberExprNoBF Arguments  { raise; result = makeFunctionCallNode($1, $2); }
  | CallExprNoBF Arguments    { raise; result = makeFunctionCallNode($1, $2); }
  | CallExprNoBF '[' Expr ']' { raise; result = BracketAccessorNode.new($1, $3); }
  | CallExprNoBF '.' IDENT    { raise; result = DotAccessorNode.new($1, *$3); }
  ;

  Arguments:
    '(' ')'               { raise; result = ArgumentsNode.new(); }
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
    '{' '}'                             { raise; result = BlockNode.new(new SourceElements); DBG($$, @1, @2); }
  | '{' SourceElements '}'              { raise; result = BlockNode.new($2->release()); DBG($$, @1, @3); }
  ;

  VariableStatement:
    VAR VariableDeclarationList ';'     { raise; result = VarStatementNode.new($2.head); DBG($$, @1, @3); }
  | VAR VariableDeclarationList error   { raise; result = VarStatementNode.new($2.head); DBG($$, @1, @2); AUTO_SEMICOLON; }
  ;

  VariableDeclarationList:
    VariableDeclaration                 { raise; result.head = $1; 
                                          $$.tail = $$.head; }
  | VariableDeclarationList ',' VariableDeclaration
                                        { raise; result.head = $1.head;
                                          $1.tail->next = $3;
                                          $$.tail = $3; }
  ;

  VariableDeclarationListNoIn:
    VariableDeclarationNoIn             { raise; result.head = $1; 
                                          $$.tail = $$.head; }
  | VariableDeclarationListNoIn ',' VariableDeclarationNoIn
                                        { raise; result.head = $1.head;
                                          $1.tail->next = $3;
                                          $$.tail = $3; }
  ;

  VariableDeclaration:
    IDENT                               { raise; result = VarDeclNode.new(*$1, 0, VarDeclNode::Variable); }
  | IDENT Initializer                   { raise; result = VarDeclNode.new(*$1, $2, VarDeclNode::Variable); }
  ;

  VariableDeclarationNoIn:
    IDENT                               { raise; result = VarDeclNode.new(*$1, 0, VarDeclNode::Variable); }
  | IDENT InitializerNoIn               { raise; result = VarDeclNode.new(*$1, $2, VarDeclNode::Variable); }
  ;

  ConstStatement:
    CONST ConstDeclarationList ';' { raise; result = VarStatementNode.new($2.head); DBG($$, @1, @3); }
  | CONST ConstDeclarationList error
                                        { raise; result = VarStatementNode.new($2.head); DBG($$, @1, @2); AUTO_SEMICOLON; }
  ;

  ConstDeclarationList:
    ConstDeclaration                    { raise; result.head = $1; 
                                          $$.tail = $$.head; }
  | ConstDeclarationList ',' ConstDeclaration
                                        { raise; result.head = $1.head;
                                          $1.tail->next = $3;
                                          $$.tail = $3; }
  ;

  ConstDeclaration:
    IDENT                               { raise; result = VarDeclNode.new(*$1, 0, VarDeclNode::Constant); }
  | IDENT Initializer                   { raise; result = VarDeclNode.new(*$1, $2, VarDeclNode::Constant); }
  ;

  Initializer:
    '=' AssignmentExpr                  { raise; result = AssignExprNode.new($2); }
  ;

  InitializerNoIn:
    '=' AssignmentExprNoIn              { raise; result = AssignExprNode.new($2); }
  ;

  EmptyStatement:
    ';'                                 { raise; result = EmptyStatementNode.new(); }
  ;

  ExprStatement:
    ExprNoBF ';'                        { raise; result = ExprStatementNode.new($1); DBG($$, @1, @2); }
  | ExprNoBF error                      { raise; result = ExprStatementNode.new($1); DBG($$, @1, @1); AUTO_SEMICOLON; }
  ;

  IfStatement:
    IF '(' Expr ')' Statement
                                        { raise; result = IfNode.new($3, $5, 0); DBG($$, @1, @4); } =IF_WITHOUT_ELSE
  | IF '(' Expr ')' Statement ELSE Statement
                                        { raise; result = IfNode.new($3, $5, $7); DBG($$, @1, @4); }
  ;

  IterationStatement:
    DO Statement WHILE '(' Expr ')' ';'    { raise; result = DoWhileNode.new($2, $5); DBG($$, @1, @3); }
  | DO Statement WHILE '(' Expr ')' error  { raise; result = DoWhileNode.new($2, $5); DBG($$, @1, @3); } /* Always performs automatic semicolon insertion. */
  | WHILE '(' Expr ')' Statement        { raise; result = WhileNode.new($3, $5); DBG($$, @1, @4); }
  | FOR '(' ExprNoInOpt ';' ExprOpt ';' ExprOpt ')' Statement
                                        { raise; result = ForNode.new($3, $5, $7, $9); DBG($$, @1, @8); }
  | FOR '(' VAR VariableDeclarationListNoIn ';' ExprOpt ';' ExprOpt ')' Statement
                                        { raise; result = ForNode.new($4.head, $6, $8, $10); DBG($$, @1, @9); }
  | FOR '(' LeftHandSideExpr IN Expr ')' Statement
                                        {
                                            ExpressionNode* n = $3;
                                            if (!n->isLocation())
                                                YYABORT;
                                            $$ = ForInNode.new(n, $5, $7);
                                            DBG($$, @1, @6);
                                        }
  | FOR '(' VAR IDENT IN Expr ')' Statement
                                        { raise; result = ForInNode.new(*$4, 0, $6, $8); DBG($$, @1, @7); }
  | FOR '(' VAR IDENT InitializerNoIn IN Expr ')' Statement
                                        { raise; result = ForInNode.new(*$4, $5, $7, $9); DBG($$, @1, @8); }
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
    CONTINUE ';'                        { raise; result = ContinueNode.new(); DBG($$, @1, @2); }
  | CONTINUE error                      { raise; result = ContinueNode.new(); DBG($$, @1, @1); AUTO_SEMICOLON; }
  | CONTINUE IDENT ';'                  { raise; result = ContinueNode.new(*$2); DBG($$, @1, @3); }
  | CONTINUE IDENT error                { raise; result = ContinueNode.new(*$2); DBG($$, @1, @2); AUTO_SEMICOLON; }
  ;

  BreakStatement:
    BREAK ';'                           { raise; result = BreakNode.new(); DBG($$, @1, @2); }
  | BREAK error                         { raise; result = BreakNode.new(); DBG($$, @1, @1); AUTO_SEMICOLON; }
  | BREAK IDENT ';'                     { raise; result = BreakNode.new(*$2); DBG($$, @1, @3); }
  | BREAK IDENT error                   { raise; result = BreakNode.new(*$2); DBG($$, @1, @2); AUTO_SEMICOLON; }
  ;

  ReturnStatement:
    RETURN ';'                          { raise; result = ReturnNode.new(0); DBG($$, @1, @2); }
  | RETURN error                        { raise; result = ReturnNode.new(0); DBG($$, @1, @1); AUTO_SEMICOLON; }
  | RETURN Expr ';'                     { raise; result = ReturnNode.new($2); DBG($$, @1, @3); }
  | RETURN Expr error                   { raise; result = ReturnNode.new($2); DBG($$, @1, @2); AUTO_SEMICOLON; }
  ;

  WithStatement:
    WITH '(' Expr ')' Statement         { raise; result = WithNode.new($3, $5); DBG($$, @1, @4); }
  ;

  SwitchStatement:
    SWITCH '(' Expr ')' CaseBlock       { raise; result = SwitchNode.new($3, $5); DBG($$, @1, @4); }
  ;

  CaseBlock:
    '{' CaseClausesOpt '}'              { raise; result = CaseBlockNode.new($2.head, 0, 0); }
  | '{' CaseClausesOpt DefaultClause CaseClausesOpt '}'
                                        { raise; result = CaseBlockNode.new($2.head, $3, $4.head); }
  ;

  CaseClausesOpt:
    /* nothing */                       { raise; result.head = 0; $$.tail = 0; }
  | CaseClauses
  ;

  CaseClauses:
    CaseClause                          { raise; result.head = ClauseListNode.new($1);
                                          $$.tail = $$.head; }
  | CaseClauses CaseClause              { raise; result.head = $1.head; 
                                          $$.tail = ClauseListNode.new($1.tail, $2); }
  ;

  CaseClause:
    CASE Expr ':'                       { raise; result = CaseClauseNode.new($2); }
  | CASE Expr ':' SourceElements        { raise; result = CaseClauseNode.new($2, $4->release()); }
  ;

  DefaultClause:
    DEFAULT ':'                         { raise; result = CaseClauseNode.new(0); }
  | DEFAULT ':' SourceElements          { raise; result = CaseClauseNode.new(0, $3->release()); }
  ;

  LabelledStatement:
    IDENT ':' Statement                 { $3->pushLabel(*$1); $$ = LabelNode.new(*$1, $3); }
  ;

  ThrowStatement:
    THROW Expr ';'                      { raise; result = ThrowNode.new($2); DBG($$, @1, @3); }
  | THROW Expr error                    { raise; result = ThrowNode.new($2); DBG($$, @1, @2); AUTO_SEMICOLON; }
  ;

  TryStatement:
    TRY Block FINALLY Block             { raise; result = TryNode.new($2, CommonIdentifiers::shared()->nullIdentifier, 0, $4); DBG($$, @1, @2); }
  | TRY Block CATCH '(' IDENT ')' Block { raise; result = TryNode.new($2, *$5, $7, 0); DBG($$, @1, @2); }
  | TRY Block CATCH '(' IDENT ')' Block FINALLY Block
                                        { raise; result = TryNode.new($2, *$5, $7, $9); DBG($$, @1, @2); }
  ;

  DebuggerStatement:
    DEBUGGER ';'                        { raise; result = EmptyStatementNode.new(); DBG($$, @1, @2); }
  | DEBUGGER error                      { raise; result = EmptyStatementNode.new(); DBG($$, @1, @1); AUTO_SEMICOLON; }
  ;

  FunctionDeclaration:
    FUNCTION IDENT '(' ')' '{' FunctionBody '}' { raise; result = FuncDeclNode.new(*$2, $6); DBG($6, @5, @7); }
  | FUNCTION IDENT '(' FormalParameterList ')' '{' FunctionBody '}'
                                        { raise; result = FuncDeclNode.new(*$2, $4.head, $7); DBG($7, @6, @8); }
  ;

  FunctionExpr:
    FUNCTION '(' ')' '{' FunctionBody '}' { raise; result = FuncExprNode.new(CommonIdentifiers::shared()->nullIdentifier, $5); DBG($5, @4, @6); }
  | FUNCTION '(' FormalParameterList ')' '{' FunctionBody '}' { raise; result = FuncExprNode.new(CommonIdentifiers::shared()->nullIdentifier, $6, $3.head); DBG($6, @5, @7); }
  | FUNCTION IDENT '(' ')' '{' FunctionBody '}' { raise; result = FuncExprNode.new(*$2, $6); DBG($6, @5, @7); }
  | FUNCTION IDENT '(' FormalParameterList ')' '{' FunctionBody '}' { raise; result = FuncExprNode.new(*$2, $7, $4.head); DBG($7, @6, @8); }
  ;

  FormalParameterList:
    IDENT                               { raise; result.head = ParameterNode.new(*$1);
                                          $$.tail = $$.head; }
  | FormalParameterList ',' IDENT       { raise; result.head = $1.head;
                                          $$.tail = ParameterNode.new($1.tail, *$3); }
  ;

  FunctionBody:
    /* not in spec */           { raise; result = FunctionBodyNode.new(new SourceElements); }
  | SourceElements              { raise; result = FunctionBodyNode.new($1->release()); }
  ;

  SourceElements:
    SourceElement                       { raise; result = new SourceElementsStub; $$->append($1); }
  | SourceElements SourceElement        { raise; result->append($2); }
  ;

  SourceElement:
    FunctionDeclaration                 { raise; result = $1; }
  | Statement                           { raise; result = $1; }
  ;
end

---- header
  require "rkelly/nodes"
