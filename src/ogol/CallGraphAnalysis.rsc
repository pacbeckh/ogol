module ogol::CallGraphAnalysis

import ogol::Syntax;
import ParseTree;
import IO;
import analysis::graphs::Graph;
import Set;

alias Result = tuple[Calls calls, set[str] allDefs];
alias Calls = Graph[str];

alias FunctionDefinitions = lrel[str functionName, str scopeName]; // Function definitions

public Result callAnalysis() {
    Program p = parse(#start[Program], |project://Ogol/input/octagon.ogol|).top;
    result = analyzeCommands("global", p.commands, <{}, {}>, []);

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


Result analyzeCommands(str scopeName, Command* commands, Result result, FunctionDefinitions defs) {
	newDefs = [*getDefinition(scopeName, cmd) | cmd <- commands ];
	defs = newDefs + defs;
	
	result.allDefs +=  {"<scope>/<name>" | <name, scope> <- newDefs};
	
	for(cmd <- commands){
		result = analyzeCommand(scopeName, cmd, result, defs);
	}
	return result;
}

FunctionDefinitions getDefinition(str scopeName, (Command) `to <FunId fid> <VarId* args> <Command* commands> end`)
	= [<"<fid>", scopeName>];

default FunctionDefinitions getDefinition(str scopeName, Command command)
	= [];

Result analyzeCommand(str scopeName, (Command) `to <FunId fid> <VarId* args> <Command* commands> end`, Result result, FunctionDefinitions defs)
	= analyzeCommands("<scopeName>/<fid>", commands, result, defs);

Result analyzeCommand(str scopeName, (Command)`<FunCall funCall>`, Result result, FunctionDefinitions defs) {
	list[str] possibleScopes = defs["<funCall.id>"];
	
	if(isEmpty(possibleScopes)) {
		result.calls = result.calls + <scopeName, "***undefined:<funCall.id>***">;
	} else {
		result.calls = result.calls + <scopeName, "<possibleScopes[0]>/<funCall.id>">;
	}
	return result;
}

Result analyzeCommand(str scopeName, (Command)`repeat <Expr e> <Block b>`, Result result, FunctionDefinitions defs) 
	= analyzeCommands("<scopeName>", b.commands, result, defs);

Result analyzeCommand(str scopeName, (Command)`ifelse <Expr e> <Block i> <Block j>`, Result result, FunctionDefinitions defs) {
	result = analyzeCommands("<scopeName>", i.commands, result, defs);
	return analyzeCommands("<scopeName>", j.commands, result, defs);
}


default Result analyzeCommand(str scopeName, Command command, Result result, FunctionDefinitions defs) 
	= result;

