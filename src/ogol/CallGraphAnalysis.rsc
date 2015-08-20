module ogol::CallGraphAnalysis

import ogol::Syntax;
import ParseTree;
import IO;
import analysis::graphs::Graph;


alias Result = tuple[Calls calls, FunctionDefinitions defs, set[str] allDefs];
alias Calls = Graph[str];

alias FunctionDefinitions = lrel[str functionName, str scopeName]; // Function definitions

public Result callAnalysis() {
    Program p = parse(#start[Program], |project://Ogol/input/dashed.ogol|).top;
    result = definitionsInCommands("global", p.commands, <{},[], {}>);

	println("-------------------------------------------------");
	println("Analysis:\n");
	    
    println("Unused functions: <result.allDefs - canBeReached(result.calls, "global")>");
    for(str def <- result.allDefs){ 
    	println("<def> -\> <canBeReached(result.calls, def)>");
    }
    
    println("\n-------------------------------------------------");    
    return result;
}

public set[str] canBeReached(Calls calls, str from) = (calls+)[from];


Result definitionsInCommands(str scopeName, Command* commands, Result result) {
	x = result.defs;
	
	for(cmd <- commands){
		result = definitionsInCommand(scopeName, cmd, result);
	}
	return <result.calls, x, result.allDefs>;
}

Result definitionsInCommand(str scopeName, (Command) `to <FunId fid> <VarId* args> <Command* commands> end`, Result result) {
	defs = result.defs + <"<fid>", scopeName>;
	
	result = definitionsInCommands("<scopeName>/<fid>", commands, <result.calls, defs, result.allDefs>);
	return <result.calls, defs, result.allDefs + "<scopeName>/<fid>" >;
}

Result definitionsInCommand(str scopeName, (Command)`<FunCall funCall>`, Result result) {
	list[str] possibleScopes = result.defs["<funCall.id>"];
	
	if(size(possibleScopes) > 0) {
		result.calls = result.calls + <scopeName, "<possibleScopes[0]>/<funCall.id>">;
	} else {
		println("NoSuchMethodException <funCall.id>");	
		println(result.defs);
	}
	
	return result; 
}

Result definitionsInCommand(str scopeName, (Command)`repeat <Expr e> <Block b>`, Result result) {
	return definitionsInCommands("<scopeName>", b.commands, result);
}

Result definitionsInCommand(str scopeName, (Command)`ifelse <Expr e> <Block i> <Block j>`, Result result) {
	result = definitionsInCommands("<scopeName>", i.commands, result);
	return definitionsInCommands("<scopeName>", j.commands, result);
}


default Result definitionsInCommand(str scopeName, Command command, Result result) {
	return result;
}

