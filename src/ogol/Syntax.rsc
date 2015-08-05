@doc{

Ogol syntax summary

Program: list of command

Command:
 * Control flow: 
  if Expr Block
  ifelse Expr Block Block
  while Block Block
  repeat Expr Block
 * Drawing
  moving: forward Expr, back Expr 
  turning: right Expr, left Expr, 
  pen: pendown, penup, 
 * Procedures
  definition: to Name [Vars...] Command... end
  call: Name Expr... ;
 
Block: [Command...]  
 
Expressions
 * variables :x, :y, :angle etc.
 * number: 1, 2, -3 etc.
 * boolean: true, false
 * arithmetic: +, *, /, -
 * comparison: >, <, >=, <=, =, !=
 * logical: &&, ||

Reserved keywords
 if, ifelse, while, repeat, forward, back, right, left, pendown, 
 penup, to, true, false, end

Bonus:
 - add literal for colors
 - support setpencolor

}
module ogol::Syntax

start syntax Program = Command*; 
