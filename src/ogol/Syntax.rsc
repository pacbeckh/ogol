module ogol::Syntax

/*

Ogol syntax summary

Program: Command...

Command:
 * Control flow:
  if Expr Block
  ifelse Expr Block Block
  while Expr Block
  repeat Expr Block
 * Drawing (mind the closing semicolons)
  forward Expr; fd Expr; back Expr; bk Expr; home;
  right Expr; rt Expr; left Expr; lt Expr;
  pendown; pd; penup; pu;
 * Procedures
  definition: to Name [Var...] Command... end
  call: Name Expr... ;

Block: [Command...]

Expressions
 * Variables :x, :y, :angle, etc.
 * Number: 1, 2, -3, 0.7, -.1, etc.
 * Boolean: true, false
 * Arithmetic: +, *, /, -
 * Comparison: >, <, >=, <=, =, !=
 * Logical: &&, ||

Reserved keywords
 if, ifelse, while, repeat, forward, back, right, left, pendown, 
 penup, to, true, false, end, home

Bonus:
 - add literal for colors
 - support setpencolor

*/

start syntax Program = Commands commands;

keyword Reserved = "if" | "ifelse" | "while"| "repeat"
					| "forward" | "fd" | "back" | "bk" | "right" | "rt" | "left" | "lt"
					| "pendown" | "pd" | "penup" | "pu" | "home"
					| "to" | "true" | "false" | "end";

lexical Boolean = "true" | "false";

lexical Number = "-"? ([0-9]* ".")? [0-9]+ !>> [0-9];

lexical Decimal = "." [0-9]+;

syntax Expr = VarId
			| Number
			| Boolean
			| left Expr "/" Expr
			> left Expr "*" Expr
			> left (
			      Expr "+" Expr
			    | Expr "-" Expr
			  )
			> left (
			      Expr "\>" Expr
				| Expr "\<" Expr
				| Expr "\>=" Expr
				| Expr "\<=" Expr
				| Expr "=" Expr
				| Expr "!=" Expr
			  )
			> left Expr "&&" Expr
			> left Expr "||" Expr
			;


syntax Command =
 /*Drawings*/	   ("left" | "lt") Expr ";"
				 | ("right" | "rt") Expr ";"
				 | ("forward" | "fd") Expr ";"
				 | ("back" | "bk") Expr ";"
				 | ("penup" | "pu") ";"
				 | ("pendown" | "pd") ";"
				 | "home" ";"
/*Control flow*/ | "if" Expr Block
				 | "ifelse" Expr Block Block
				 | "while" Expr Block
				 | "repeat" Expr Block
/*Procedures*/	 | FunDef
				 | FunCall
				 ;

syntax Commands = Command*;
syntax FunCall = FunId id Expr* exprs ";";
syntax FunDef = "to" FunId id VarId* params Commands body "end";

syntax Block = "[" Commands commands "]";

lexical VarId = ":" ([a-zA-Z][a-zA-Z0-9]*) \Reserved !>> [a-zA-Z0-9];
lexical FunId = ([a-zA-Z][a-zA-Z0-9]*) \Reserved !>> [a-zA-Z0-9] ;


layout Standard = WhitespaceOrComment* !>> [\ \t\n\r] !>> "--";

lexical WhitespaceOrComment
  = whitespace: Whitespace
  | comment: Comment
  ;

lexical Whitespace
  = [\ \t\n\r]
  ;

lexical Comment
  = @category="Comment" "--" ![\n\r]* $
  ;
