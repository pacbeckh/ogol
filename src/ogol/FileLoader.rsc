module ogol::FileLoader

import util::IDE;
import ogol::Eval;
import ogol::Syntax;
import ParseTree;
import IO;
import vis::Figure;
import vis::ParseTree;
import vis::Render;
import ogol::Canvas2JS;

public void main(list[str] args) {
	str fileContent = readFile(|project://Ogol/input/dashed.ogol|);
	
	Program program = parse(#start[Program], fileContent).top;
	result = evalProgram(program);
	writeFile(|project://Ogol/input/ogol.js|, canvas2js(result));		
}