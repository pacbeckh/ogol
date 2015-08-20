module ogol::EvalTest

import ParseTree;
import ogol::Syntax;
import ogol::Eval;
import ogol::Canvas;
import util::Math;
import IO;

public bool testDesugar(i, j) {
	return desugar(i) == j;
}

//Desugar
test bool desugarForward() = testDesugar((Program)`fd 1;`, (Program)`forward 1;`);
test bool desugarBack() = testDesugar((Program)`bk 1;`, (Program)`back 1;`);
test bool desugarRight() = testDesugar((Program)`rt 1;`, (Program)`right 1;`);
test bool desugarLeft() = testDesugar((Program)`lt 1;`, (Program)`left 1;`);
test bool desugarPenDown() = testDesugar((Program)`pd;`, (Program)`pendown;`);
test bool desugarPenUp() = testDesugar((Program)`pu;`, (Program)`penup;`);
test bool desugarIf() = testDesugar((Program)`if 1 [ fd 1; ]`, (Program)`ifelse 1 [forward 1;] []`);

test bool desugarBlock() = testDesugar((Program)`repeat 4 [ rt 10;]`, (Program)`repeat 4 [ right 10;]`);
test bool desugarFunction() = testDesugar(
  (Program)`to squareDashTrirl :n repeat 36 [squareDash :n :n; rt 10;] end`, 
  (Program)`to squareDashTrirl :n repeat 36 [squareDash :n :n; right 10;] end`);
//Expr
//  VarId
test bool evalVarId1() = eval((Expr)`:t`, ((VarId)`:t`: number(10.0))) == number(10.0);
//test bool evalVarIdError() = eval((Expr)`:t`, ((Expr)`:x`: number(10.0)));

// Number
test bool evalNumber1() = eval((Expr)`1`, ()) == number(1.);

// Boolean
test bool evalBool1() = eval((Expr)`true`, ()) == boolean(true);
test bool evalBool2() = eval((Expr)`false`, ()) == boolean(false);

// Parentheses
test bool testParentheses() = eval((Expr)`(1)`, ()) == number(1.);

// Arithmatic
test bool evalDivision1() = eval((Expr)`4 / 2`, ()) == number(2.);
test bool evalDivision2() = eval((Expr)`4 / :q`, ((VarId)`:q` : number(5.0))) == number(0.8);
test bool evalDivision3() = eval((Expr)`:q / :q`, ((VarId)`:q` : number(5.0))) == number(1.);
test bool evalMultiplication1() = eval((Expr)`4 * 2`, ()) == number(8.);
test bool evalMultiplication2() = eval((Expr)`4 * :q`, ((VarId)`:q` : number(5.0))) == number(20.0);
test bool evalMultiplication3() = eval((Expr)`:q * :q`, ((VarId)`:q` : number(5.0))) == number(25.00);
test bool evalMinus1() = eval((Expr)`4 - 2`, ()) == number(2.);
test bool evalMinus2() = eval((Expr)`4 - :q`, ((VarId)`:q` : number(5.0))) == number(-1.0);
test bool evalMinus3() = eval((Expr)`:q - :q`, ((VarId)`:q` : number(5.0))) == number(0.0);
test bool evalPlus1() = eval((Expr)`4 + 2`, ()) == number(6.);
test bool evalPlus2() = eval((Expr)`-4 + :q`, ((VarId)`:q` : number(5.0))) == number(1.0);
test bool evalPlus3() = eval((Expr)`:q + :q`, ((VarId)`:q` : number(5.0))) == number(10.0);

// Comparison > < >= <= != =
test bool evalLT1() = eval((Expr)`1 \< 2`, ()) == boolean(true);
test bool evalLT2() = eval((Expr)`1 \< 1`, ()) == boolean(false);
test bool evalLT3() = eval((Expr)`2 \< 1`, ()) == boolean(false);
test bool evalGT1() = eval((Expr)`2 \> 1`, ()) == boolean(true);
test bool evalGT2() = eval((Expr)`1 \> 2`, ()) == boolean(false);
test bool evalGT3() = eval((Expr)`1 \> 1`, ()) == boolean(false);
test bool evalLTE1() = eval((Expr)`1 \<= 2`, ()) == boolean(true);
test bool evalLTE2() = eval((Expr)`1 \<= 1`, ()) == boolean(true);
test bool evalLTE3() = eval((Expr)`2 \<= 1`, ()) == boolean(false);
test bool evalGTE1() = eval((Expr)`2 \>= 1`, ()) == boolean(true);
test bool evalGTE2() = eval((Expr)`1 \>= 1`, ()) == boolean(true);
test bool evalGTE3() = eval((Expr)`1 \>= 2`, ()) == boolean(false);
test bool evalEQ1() = eval((Expr)`true = true`, ()) == boolean(true);
test bool evalEQ2() = eval((Expr)`true = false`, ()) == boolean(false);
test bool evalEQ3() = eval((Expr)`false = false`, ()) == boolean(true);
test bool evalEQ4() = eval((Expr)`1 = 2`, ()) == boolean(false);
test bool evalEQ5() = eval((Expr)`1 = 1`, ()) == boolean(true);
test bool evalNEQ1() = eval((Expr)`true != true`, ()) == boolean(false);
test bool evalNEQ2() = eval((Expr)`true != false`, ()) == boolean(true);
test bool evalNEQ3() = eval((Expr)`false != false`, ()) == boolean(false);
test bool evalNEQ4() = eval((Expr)`1 != 2`, ()) == boolean(true);
test bool evalNEQ5() = eval((Expr)`1 != 1`, ()) == boolean(false);

// Logical
test bool evalOR1() = eval((Expr)`true || true`, ()) == boolean(true);
test bool evalOR2() = eval((Expr)`true || false`, ()) == boolean(true);
test bool evalOR3() = eval((Expr)`false || false`, ()) == boolean(false);
test bool evalAND1() = eval((Expr)`true && false`, ()) == boolean(false);
test bool evalAND2() = eval((Expr)`false && false`, ()) == boolean(false);
test bool evalAND3() = eval((Expr)`true && true`, ()) == boolean(true);


//public State baseState = <<0.0,true,<0.0,0.0>>, []>;

public State baseState(real direction, bool pendown, Point position, Canvas canvas) {
	return <<direction,pendown,position>, canvas>;
}

//Commands
test bool evalPenUp1() = evalCommand((Command)`penup;`, (), (), baseState(0.0,false, <0.0,0.0>, [])) == <<0.0,false,<0.0,0.0>>, []>;
test bool evalPenUp2() = evalCommand((Command)`penup;`, (), (), baseState(0.0,true, <0.0,0.0>, [])) == <<0.0,false,<0.0,0.0>>, []>;

test bool evalPenDown1() = evalCommand((Command)`pendown;`, (), (), baseState(0.0,false, <0.0,0.0>, [])) == <<0.0,true,<0.0,0.0>>, []>;
test bool evalPenDown2() = evalCommand((Command)`pendown;`, (), (), baseState(0.0,true, <0.0,0.0>, [])) == <<0.0,true,<0.0,0.0>>, []>;

test bool evalRight1() = evalCommand((Command)`right 100;`, (), (), baseState(266.0,false, <0.0,0.0>, [])) == <<6.0,false,<0.0,0.0>>, []>;
test bool evalRight2() = evalCommand((Command)`right -80;`, (), (), baseState(20.0,false, <0.0,0.0>, [])) == <<300.0,false,<0.0,0.0>>, []>;
test bool evalRight3() = evalCommand((Command)`right 20;`, (), (), baseState(20.0,false, <0.0,0.0>, [])) == <<40.0,false,<0.0,0.0>>, []>;

test bool evalLeft1() = evalCommand((Command)`left 100;`, (), (), baseState(266.0,false, <0.0,0.0>, [])) == <<166.0,false,<0.0,0.0>>, []>;
test bool evalLeft2() = evalCommand((Command)`left -80;`, (), (), baseState(20.0,false, <0.0,0.0>, [])) == <<100.0,false,<0.0,0.0>>, []>;
test bool evalLeft3() = evalCommand((Command)`left 40;`, (), (), baseState(20.0,false, <0.0,0.0>, [])) == <<340.0,false,<0.0,0.0>>, []>;
test bool evalLeft4() = evalCommand((Command)`left 180;`, (), (), baseState(180.0,false, <0.0,0.0>, [])) == <<0.0,false,<0.0,0.0>>, []>;

bool evalPosition(Command c, State input, State expected) {
	State out = evalCommand(c, (),(), input);
	println(out.turtle.position);
	println(expected.turtle.position);
	return round(out.turtle.position.x, 0.1) == expected.turtle.position.x &&
		round(out.turtle.position.y, 0.1) == expected.turtle.position.y; 
}

test bool evalForward1() = evalPosition((Command)`forward 100;`, baseState(0.0,false, <0.0,0.0>, []), <<0.0,false,<0.0,100.0>>, []>);
test bool evalForward2() = evalPosition((Command)`forward -100;`, baseState(0.0,false, <0.0,0.0>, []), <<0.0,false,<0.0,-100.0>>, []>);
test bool evalForward3() = evalPosition((Command)`forward 100;`, baseState(90.0,false, <0.0,0.0>, []), <<90.0,false,<100.0, 0.0>>, []>);
test bool evalForward4() = evalPosition((Command)`forward -100;`, baseState(90.0,false, <0.0,0.0>, []), <<90.0,false,<-100.0, 0.0>>, []>);
test bool evalForward5() = evalPosition((Command)`forward 100;`, baseState(225.0,false, <50.0,20.0>, []), <<90.0,false,<-20.7, -50.7>>, []>);
test bool evalForwardLine1() = evalCommand((Command)`forward 100;`,() ,(), baseState(0.0,true, <0.0,0.0>, [])) ==  <<0.0,true,<0.0,100.0>>, [line(<0.0,0.0>,<0.0,100.0>)]>;


test bool evalBack1() = evalPosition((Command)`back -100;`, baseState(0.0,false, <0.0,0.0>, []), <<0.0,false,<0.0,100.0>>, []>);
test bool evalBack2() = evalPosition((Command)`back 100;`, baseState(0.0,false, <0.0,0.0>, []), <<0.0,false,<0.0,-100.0>>, []>);
test bool evalBack3() = evalPosition((Command)`back -100;`, baseState(90.0,false, <0.0,0.0>, []), <<90.0,false,<100.0, 0.0>>, []>);
test bool evalBack4() = evalPosition((Command)`back 100;`, baseState(90.0,false, <0.0,0.0>, []), <<90.0,false,<-100.0, 0.0>>, []>);
test bool evalBack5() = evalPosition((Command)`back -100;`, baseState(225.0,false, <50.0,20.0>, []), <<90.0,false,<-20.7, -50.7>>, []>);

test bool evalHome() = evalCommand((Command)`home;`, (), (), baseState(0.0,false, <10.0,10.0>, [])) == <<0.0,false,<0.0,0.0>>, []>;


test bool evalIfElse1() = evalCommand((Command)`ifelse true [forward 100;] [ back 100;]` , (), (), baseState(0.0,false, <0.0,0.0>, [])) == <<0.0,false,<0.0,100.0>>, []>;
test bool evalIfElse2() = evalCommand((Command)`ifelse false [forward 100;] [ back 100;]` , (), (), baseState(0.0,false, <0.0,0.0>, [])) == <<0.0,false,<0.0,-100.0>>, []>;

test bool evalFile1() {evalProgram(parse(#start[Program], readFile(|project://Ogol/input/test.ogol|)).top); return true;}
test bool evalFile1() {evalProgram(parse(#start[Program], readFile(|project://Ogol/input/trees.ogol|)).top); return true;}
test bool evalFile2() {evalProgram(parse(#start[Program], readFile(|project://Ogol/input/octagon.ogol|)).top); return true;}


	