module ogol::Eval

import ogol::Syntax;
import ogol::Canvas;
import String;
import IO;
import util::Math;
import List;
import Type;
import ParseTree;

alias FunEnv = map[FunId id, FunDef def];

alias VarEnv = map[VarId id, Value val];


data Value
  = boolean(bool b)
  | number(real i)
  ;

/*
         +y
         |
         |
         |
-x ------+------- +x
         |
         |
         |
        -y

NB: home = (0, 0)
*/




alias Turtle = tuple[real dir, bool pendown, Point position];

alias State = tuple[Turtle turtle, Canvas canvas];

// Top-level eval function
public Canvas evalProgram(p:(Program)`<Command* cmds>`) {
	p = desugar(p);
	funenv = collectFunDefs(p);
	
	state = evalCommands(p.commands, funenv, (), <<0.0, true,  <0.0,0.0>>,[]>);
	
	return state.canvas;
}

public Program desugar(Program p) {
	return visit (p) {
		case (Command) `fd <Expr e>;`
		  => (Command) `forward <Expr e>;`
	    case (Command) `bk <Expr e>;`
	      => (Command) `back <Expr e>;`
	    case (Command) `rt <Expr e>;`
	      => (Command) `right <Expr e>;`
	    case (Command) `lt <Expr e>;`
	      => (Command) `left <Expr e>;`
	    case (Command) `pu;`
	      => (Command) `penup;`
	    case (Command) `pd;`
	      => (Command) `pendown;`
	    case (Command) `if <Expr e> <Block b>`
	      => (Command) `ifelse <Expr e> <Block b> []`
	}
}

//TODO: Error on duplicates?
FunEnv collectFunDefs(Program p) {
	return (f.id : f | /FunDef f := p);
}

public State evalCommand((Command)`<FunCall funCall>`, FunEnv fenv, VarEnv venv, State state) {
	FunDef target = fenv[funCall.id];
	venv = bind(funCall, target, venv);
	state = evalCommand(target.body, fenv, venv, state);
	return state;
}

//Eval Command
public State evalCommand((Command)`penup;`, FunEnv fenv, VarEnv venv, State state) {
	return state.turtle.pendown = false;
}

public State evalCommand((Command)`pendown;`, FunEnv fenv, VarEnv venv, State state) {
	return state.turtle.pendown = true;
}

public State evalCommand((Command)`right <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyRotation(n, state);
}

public State evalCommand((Command)`left <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyRotation(-n, state);
}

public State evalCommand((Command)`left <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyRotation(-n, state);
}

public State evalCommand((Command)`forward <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyMovement(n, state);
}
public State evalCommand((Command)`back <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyMovement(-n, state);
}

public State evalCommand((Command)`home;`, FunEnv fenv, VarEnv venv, State state) {
	return state.turtle.position = <0.0,0.0>;
}

public State evalCommand((Command)`ifelse <Expr e> <Block i> <Block j>`, FunEnv fenv, VarEnv venv, State state) {
	boolean(b) = eval(e, venv);
	return b ? evalCommand(i, fenv, venv, state) : evalCommand(j, fenv, venv, state);
}

public State evalCommand((Command)`repeat <Expr e> <Block b>`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	for( _ <- [0..toInt(n)]) {
		state = evalCommand(b, fenv, venv, state);
	};
	return state;
}

public State evalCommand((Command)`<FunDef f>`, FunEnv fenv, VarEnv venv, State state) {
	return state;
}

public State evalCommand((Block)`[<Command* commands>]`, FunEnv fenv, VarEnv venv, State state) {
	return evalCommands(commands, fenv, venv, state);
}

public State evalCommands(cmds, FunEnv fenv, VarEnv venv, State state) {
	for (Command c <- cmds) {
		state = evalCommand(c, fenv, venv, state);
	};
	return state;
}

public default State evalCommand((Command)`<Command c>`, FunEnv fenv, VarEnv venv, State state) {
	throw "Could not eval command: <c>";
}

State applyMovement(real distance, State state) {
	Point from = state.turtle.position;
	
	real dy = distance * cos(state.turtle.dir * PI() / 180.0);
	real dx = distance * sin(state.turtle.dir * PI() / 180.0);
	state.turtle.position = <
		state.turtle.position.x + dx,
		state.turtle.position.y + dy
	>;
	
	if (state.turtle.pendown) {
		Point to = state.turtle.position;
		state.canvas = state.canvas + line(from, to);
	}
	return state;
}

State applyRotation(real n, State state) {
	state.turtle.dir += n;
	if (state.turtle.dir >= 360) {
		state.turtle.dir -= 360;
 	} else {
 		if  (state.turtle.dir < 0) {
 			state.turtle.dir += 360;
 		}
 	}
 	return state;
} 

VarEnv bind(call:(FunCall)`<FunId id> <Expr* exprs>;`, FunDef target, VarEnv venv) {
	return venv + ( p: eval(e, venv)  | <p, e> <- zip([p | p<-target.params], [e|e<-call.exprs]));
}


//Eval Expr
public Value eval((Expr)`<VarId x>`, VarEnv venv)
	= venv[x];
	
public Value eval((Expr)`<Number n>`, VarEnv venv)
	= number(toReal("<n>"));

public Value eval((Expr)`<Boolean b>`, VarEnv venv)
	= boolean("<b>" == "true");
	
public Value eval((Expr)`<Expr lhs> / <Expr rhs>`, VarEnv venv)
	= applyArithmatic(lhs, rhs, venv, real(real x, real y) { return x / y; });

public Value eval((Expr)`<Expr lhs> * <Expr rhs>`, VarEnv venv)
	= applyArithmatic(lhs, rhs, venv, real(real x, real y) { return x * y; });

public Value eval((Expr)`<Expr lhs> - <Expr rhs>`, VarEnv venv)
	= applyArithmatic(lhs, rhs, venv, real(real x, real y) { return x - y; });

public Value eval((Expr)`<Expr lhs> + <Expr rhs>`, VarEnv venv)
	= applyArithmatic(lhs, rhs, venv, real(real x, real y) { return x + y; });

public Value eval((Expr)`<Expr lhs> \< <Expr rhs>`, VarEnv venv)
	= applyComparison(lhs, rhs, venv, bool(real x, real y) {return x < y;});

public Value eval((Expr)`<Expr lhs> \> <Expr rhs>`, VarEnv venv)
	= applyComparison(lhs, rhs, venv, bool(real x, real y) {return x > y;});
		
public Value eval((Expr)`<Expr lhs> \<= <Expr rhs>`, VarEnv venv) 
	= applyComparison(lhs, rhs, venv, bool(real x, real y) {return x <= y;});
		
public Value eval((Expr)`<Expr lhs> \>= <Expr rhs>`, VarEnv venv)
	= applyComparison(lhs, rhs, venv, bool(real x, real y) {return x >= y;});
		
public Value eval((Expr)`<Expr lhs> = <Expr rhs>`, VarEnv venv)
    = boolean(eval(lhs, venv) == eval(rhs, venv));

public Value eval((Expr)`<Expr lhs> != <Expr rhs>`, VarEnv venv)
    = boolean(eval(lhs, venv) != eval(rhs, venv));
    
public Value eval((Expr)`<Expr lhs> && <Expr rhs>`, VarEnv venv)
    = boolean(x && y)
    when
		boolean(x) := eval(lhs, venv),
		boolean(y) := eval(rhs, venv);
		
public Value eval((Expr)`<Expr lhs> || <Expr rhs>`, VarEnv venv)
    = boolean(x || y)
    when
		boolean(x) := eval(lhs, venv),
		boolean(y) := eval(rhs, venv);
		
Value applyArithmatic(Expr lhs, Expr rhs, VarEnv venv, real(real,real) cmd) {
	switch(<eval(lhs, venv), eval(rhs,venv)>) {
		case <number(x), number(y)>: 
			return number(cmd(x,y));
		default:
			throw "Could not apply arithmatic on sides: <rhs> <lhs>";
	};
}
		
Value applyComparison(Expr lhs, Expr rhs, VarEnv venv, bool(real,real) cmd)
	= boolean(cmd(x,y))
		when
		number(x) := eval(lhs, venv),
		number(y) := eval(rhs, venv);
		
public default Value eval((Expr)`<Expr e>`, VarEnv _) {
	throw "Could not eval expr: <e>";
}
