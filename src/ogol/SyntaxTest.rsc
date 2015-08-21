module ogol::SyntaxTest

import ogol::Syntax;
import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;
import IO;

bool canParse(cl, str expr){
	try
		return /amb(_) !:= parse(cl, expr);
	catch: return false;
}

bool canParseFile(loc l) {
	return canParse(#start[Program], readFile(l));
}

//Comments
test bool comment1() = canParse(#Comment, "-- abc");

//Expr
// VarId
test bool varId1() = canParse(#Expr, ":y");
test bool varId2() = canParse(#Expr, ":y1");
test bool varId3() = canParse(#Expr, ":x \> :x");
test bool varId4() = canParse(#Expr, ":x - :x");

test bool varIdNeg1() = !canParse(#Expr, ":1x");

//Expr
//  Boolean
test bool boolean1() = canParse(#Boolean, "true");
test bool boolean2() = canParse(#Boolean, "false");
test bool booleanNeg1() = !canParse(#Boolean, "trues");
test bool booleanNeg2() = !canParse(#Boolean, "sotrue");
test bool booleanNeg3() = !canParse(#Boolean, "falser");
test bool booleanNeg4() = !canParse(#Boolean, "afalse");

//Expr
//  Number
test bool number1() = canParse(#Expr, ".09");
test bool number1() = canParse(#Number, "1");
test bool number2() = canParse(#Number, "2");
test bool number3() = canParse(#Number, "-3");
test bool number4() = canParse(#Number, "0.7");
test bool number5() = canParse(#Number, "-.1");
test bool number5() = canParse(#Number, "-2.1");
test bool number6() = canParse(#Number, "0");
test bool number7() = canParse(#Number, ".1");

test bool numberNeg1() = !canParse(#Number, "0.");
test bool numberNeg2() = !canParse(#Number, "");
test bool numberNeg3() = !canParse(#Number, "-");


test bool color1() = canParse(#RGB, "#000000");
test bool color2() = canParse(#RGB, "#0AA0a0");
test bool colorNeg1() = !canParse(#RGB, "#0AA");

//Expr
//  Arithmatic
test bool arithmatic1() = canParse(#Expr, "(1)");
test bool arithmatic1() = canParse(#Expr, "1+1");
test bool arithmatic2() = canParse(#Expr, "1 + 1");
test bool arithmatic3() = canParse(#Expr, "1 + 2");
test bool arithmatic4() = canParse(#Expr, "1+1+1");
test bool arithmatic5() = canParse(#Expr, "1-2");
test bool arithmatic6() = canParse(#Expr, "1*2");
test bool arithmatic7() = canParse(#Expr, "1/2");
test bool arithmatic8() = canParse(#Expr, "9-5+2");
test bool arithmatic9() = canParse(#Expr, "9-5*2");
test bool arithmatic10() = canParse(#Expr, "4*2/2*3");
test bool arithmatic11() = canParse(#Expr, "8*-5");
test bool arithmatic11() = canParse(#Expr, "1-false");

//Expr
// Comparison
test bool comparison1() = canParse(#Expr, "1 \> 1");
test bool comparison2() = canParse(#Expr, "1 \< 1");
test bool comparison3() = canParse(#Expr, "1 \<= 1");
test bool comparison4() = canParse(#Expr, "1 \>= 1");
test bool comparison5() = canParse(#Expr, "1 = 1");
test bool comparison6() = canParse(#Expr, "1 != 1");
// Comparison Assoc
test bool comparison7() = canParse(#Expr, "1 \> 2 = true");
test bool comparison8() = canParse(#Expr, "1=1=1");
test bool comparison8() = canParse(#Expr, "1-4\<4+2");

test bool comparisonNeg1() = !canParse(#Expr, "1 ! = 1");
test bool comparisonNeg2() = !canParse(#Expr, "1 \> = 1");
test bool comparisonNeg3() = !canParse(#Expr, "1 \< = 1");
test bool comparisonNeg4() = !canParse(#Expr, "1 =\< 1");
test bool comparisonNeg5() = !canParse(#Expr, "1 =\> 1");

//Expr
// Logical
test bool logical1() = canParse(#Expr, "1 || 2");
test bool logical2() = canParse(#Expr, "1 || 2 || 3");
test bool logical3() = canParse(#Expr, "1 && 2");
test bool logical4() = canParse(#Expr, "1 && 2 && 3");
test bool logical5() = canParse(#Expr, "1 || 1 && 2 || 1");
test bool logical6() = canParse(#Expr, "1 \>= 1 && 2 \<= 1");

test bool logicalNeg1() = !canParse(#Expr, "&& 1");
test bool logicalNeg2() = !canParse(#Expr, "1 &&");
test bool logicalNeg3() = !canParse(#Expr, "|| 1");
test bool logicalNeg4() = !canParse(#Expr, "1 ||");

//Command
// Drawing
test bool drawing1() = canParse(#Command, "left 50;");
test bool drawing2() = canParse(#Command, "lt 50;");
test bool drawing3() = canParse(#Command, "right 50;");
test bool drawing4() = canParse(#Command, "rt 1 = 1;");
test bool drawing5() = canParse(#Command, "forward 100;");
test bool drawing6() = canParse(#Command, "fd 100;");
test bool drawing7() = canParse(#Command, "back 100;");
test bool drawing8() = canParse(#Command, "bk 100;");
test bool drawing9() = canParse(#Command, "penup;");
test bool drawing10() = canParse(#Command, "pu;");
test bool drawing11() = canParse(#Command, "pendown;");
test bool drawing12() = canParse(#Command, "pd;");
test bool drawing13() = canParse(#Command, "home;");
test bool drawing14() = canParse(#Command, "fd :t;");
test bool drawing15() = canParse(#Command, "setpencolor #121212;");

test bool drawingNeg1() = !canParse(#Command, "lt 50");
test bool drawingNeg2() = !canParse(#Command, "left");
test bool drawingNeg3() = !canParse(#Command, "home left;");
test bool drawingNeg4() = !canParse(#Command, "home 1;");
test bool drawingNeg5() = !canParse(#Command, "setpencolor 1;");


//Command
// Block
test bool block1() = canParse(#Block, "[]");
test bool block2() = canParse(#Block, "[fd 12;]");
test bool block3() = canParse(#Block, "[home;]");
test bool block4() = canParse(#Block, "[ ]");

test bool blockNeg1() = !canParse(#Block, "[");
test bool blockNeg2() = !canParse(#Block, "]");
test bool blockNeg3() = !canParse(#Block, "");
test bool blockNeg4() = !canParse(#Block, "[home;");

//Command
//  If
test bool if1() = canParse(#Command, "if 1 []");
test bool if2() = canParse(#Command, "if 1 = 4 []");
test bool if3() = canParse(#Command, "if 1 [ fd 12; ]");

test bool ifNeg1() = !canParse(#Command, "if 1 fd 12;");

//Command
//If Else
test bool ifElse1() = canParse(#Command, "ifelse 1 [] []");
test bool ifElse2() = canParse(#Command, "ifelse 1 = 2 [] []");

test bool ifElseNeg1() = !canParse(#Command, "ifelse 1 []");
test bool ifElseNeg2() = !canParse(#Command, "ifelse [] []");


//Command
//  While
test bool while1() = canParse(#Command, "while 1 && 2 []");
test bool while2() = canParse(#Command, "while 1 && 2 [home;]");

test bool whileNeg1() = !canParse(#Command, "while 1");
test bool whileNeg2() = !canParse(#Command, "while []");
test bool whileNeg3() = !canParse(#Command, "while 1 2 []");
test bool whileNeg4() = !canParse(#Command, "while 1 && 2 [home;] []");


//Command
//  Repeat
test bool repeat1() = canParse(#Command, "repeat 1 && 2 []");
test bool repeat2() = canParse(#Command, "repeat 1 && 2 [home;]");

test bool repeatNeg1() = !canParse(#Command, "repeat 1");
test bool repeatNeg2() = !canParse(#Command, "repeat []");
test bool repeatNeg3() = !canParse(#Command, "repeat 1 2 []");
test bool repeatNeg4() = !canParse(#Command, "repeat 1 && 2 [home;] []");


//FunDef
test bool funDef1() = canParse(#Command, "to hello :x :y fd 10; rt 90; end");
test bool funDef2() = canParse(#Command, "to hello :x:y fd 10; rt 90; end");
test bool funDef3() = canParse(#Command, "to hello fd 10; rt 90; end");
test bool funDef4() = canParse(#Command, "to hello :x :y end");

test bool funDefNeg1() = !canParse(#Command, "to hello 1 fd 10; rt 90;");
test bool funDefNeg2() = !canParse(#Command, "to 1 fd 10; rt 90; end");
test bool funDefNeg3() = !canParse(#Command, "hello 1 fd 10; rt 90; end");
test bool funDefNeg4() = !canParse(#Command, "to 1 1 fd 10; rt 90; end");
test bool funDefNeg5() = !canParse(#Command, "to if 1 fd 10; rt 90; end");
test bool funDefNeg6() = !canParse(#Command, "to left 1 fd 10; rt 90; end");

//Call
test bool call1() = canParse(#Command, "hello 1 1;");
test bool call2() = canParse(#Command, "hello;");
test bool call3() = canParse(#Command, "hello :x true 1 \<=2;");

test bool callNeg1() = !canParse(#Command, "hello bar 1;");
test bool callNeg2() = !canParse(#Command, "hello");
test bool callNeg3() = !canParse(#Command, "_foo 1;");
test bool callNeg4() = !canParse(#Command, "to 1;");


test bool canParseBig() = canParse(#Program, "to foo :x :y forward :x; right :y; forward 100; end foo 50 100;");
//Files
test bool file1() = canParseFile(|project://Ogol/input/dashed.ogol|);
test bool file2() = canParseFile(|project://Ogol/input/octagon.ogol|);
test bool file3() = canParseFile(|project://Ogol/input/test.ogol|);
test bool file4() = canParseFile(|project://Ogol/input/trees.ogol|);

test bool fileNeg1() = !canParseFile(|project://Ogol/input/pumpkin.ogol|);

public void demo() = renderParsetree(parse(#Command, "setpencolor #121212;"));



