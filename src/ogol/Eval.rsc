module ogol::Eval

import ogol::Syntax;
import ogol::Canvas;
import String;
import IO;
import util::Math;
import List;
import Type;

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
public Canvas eval(p:(Program)`<Commands cmds>`) {
	p = desugar(p);
	funenv = collectFunDefs(p);
	state = eval(cmds, funenv, (), <<0.0, true,  <0.0,0.0>>,[]>);
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

FunEnv collectFunDefs(Program p) {
	return (f.id : f | /FunDef f := p);
}

public State eval((Command)`<FunCall funCall>`, FunEnv fenv, VarEnv venv, State state) {
	FunDef target = fenv[funCall.id];
	venv = bind(funCall, target, venv);
	state = eval(target.body, fenv, venv, state);
	return state;
}

//Eval Command
public State eval((Command)`penup;`, FunEnv fenv, VarEnv venv, State state) {
	return state.turtle.pendown = false;
}

public State eval((Command)`pendown;`, FunEnv fenv, VarEnv venv, State state) {
	return state.turtle.pendown = true;
}

public State eval((Command)`right <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyRotation(n, state);
}

public State eval((Command)`left <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyRotation(-n, state);
}

public State eval((Command)`left <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyRotation(-n, state);
}

public State eval((Command)`forward <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyMovement(n, state);
}
public State eval((Command)`back <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	return applyMovement(-n, state);
}

public State eval((Command)`home;`, FunEnv fenv, VarEnv venv, State state) {
	return state.turtle.position = <0.0,0.0>;
}

public State eval((Command)`ifelse <Expr e> <Block i> <Block j>`, FunEnv fenv, VarEnv venv, State state) {
	boolean(b) = eval(e, venv);
	return b ? eval(i, fenv, venv, state) : eval(j, fenv, venv, state);
}

public State eval((Command)`repeat <Expr e> <Block b>`, FunEnv fenv, VarEnv venv, State state) {
	number(n) = eval(e, venv);
	for( _ <- [0..toInt(n)]) {
		state = eval(b, fenv, venv, state);
	};
	return state;
}

public State eval((Command)`<FunDef f>`, FunEnv fenv, VarEnv venv, State state) {
	return state;
}

public State eval((Block)`[<Commands commands>]`, FunEnv fenv, VarEnv venv, State state) {
	return eval(commands, fenv, venv, state);
}

public State eval((Commands) `<Command* cmds>`, FunEnv fenv, VarEnv venv, State state) {
	for (Command c <- cmds) {
		state = eval(c, fenv, venv, state);
	};
	return state;
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
		
Value applyArithmatic(Expr lhs, Expr rhs, VarEnv venv, real(real,real) cmd)
	= number(cmd(x,y))
		when
		number(x) := eval(lhs, venv),
		number(y) := eval(rhs, venv);
		
Value applyComparison(Expr lhs, Expr rhs, VarEnv venv, bool(real,real) cmd)
	= boolean(cmd(x,y))
		when
		number(x) := eval(lhs, venv),
		number(y) := eval(rhs, venv);
		
public default Value eval((Expr)`<Expr e>`, VarEnv _) {
	throw "Could not eval expr: <e>";
}
