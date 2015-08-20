module ogol::NameAnalysis

import ogol::Syntax;
import ParseTree;


// Combined scope and name analysis for Ogol

alias Definitions = lrel[str varName, str scopeName, int varPos]; // variable definitions

alias Uses = rel[str varName, loc src, str scopeName, int varPos];// variable uses

// Find variables that are used in a sequence of commands

Uses varsUsedInCommands(str scopeName, Command* commands, Definitions defs) =
   { *varsUsedInCommand(scopeName, cmd, defs) | cmd <- commands };

// Find variables used in a single command -- function declaration

Uses varsUsedInCommand(str scopeName,  (Command) `to <FunId fid> <VarId* args> <Command* commands> end`, Definitions defs){
    innerScope = "<scopeName>/<fid>";
    int i = 0;
    for(arg <- args){
        defs = <"<arg>", innerScope, i> + defs;
        i += 1;
    }
    return varsUsedInCommands(innerScope, commands, defs);
}

// Find variables used in a single commands

Uses varsUsedInCommand(str scopeName,  (Command)`if <Expr e> <Block b>`, Definitions defs) {
	return getVarUses(scopeName, e, defs) +
    	   varsUsedInCommands(scopeName, b.commands, defs);
}

Uses varsUsedInCommand(str scopeName,  (Command)`ifelse <Expr e> <Block b1> <Block b2>`, Definitions defs) {
	return getVarUses(scopeName, e, defs) +
    	   varsUsedInCommands(scopeName, b1.commands, defs) +
    	   varsUsedInCommands(scopeName, b2.commands, defs);
}

Uses varsUsedInCommand(str scopeName,  (Command)`repeat <Expr e> <Block b>`, Definitions defs) {
	return getVarUses(scopeName, e, defs) +
    	   varsUsedInCommands(scopeName, b.commands, defs);
}

default Uses varsUsedInCommand(str scopeName, Command c, Definitions defs) {
	return { *getVarUses(scopeName, e, defs) | /Expr e := c };
}

// Find variables used in an expression

Uses getVarUses(str scopeName, Expr e, Definitions defs) {
	uses = {};
    for(/VarId varid := e){
        lrel[str scopeName, int varPos] vardefs = defs["<varid>"];
        if(size(vardefs) > 0){
                uses += <"<varid>", varid@\loc, vardefs[0].scopeName, vardefs[0].varPos>;
        } else
               uses += <"<varid>", varid@\loc, "***undefined***", -1>;
   };
   return uses;
}

// Try an example

Uses main(list[value] args){
    Program p = parse(#start[Program], |project://Ogol-Secret/input/dashed_nested_blocks.ogol|).top;
    return varsUsedInCommands("global", p.commands, []);
}
