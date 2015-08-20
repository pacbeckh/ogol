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
	str fileContent = readFile(|project://Ogol/input/octagon.ogol|);
	
	Tree tree = parse(#start[Program], fileContent);
	visit (tree) {
		case /Program p : {
			result = evalProgram(p);
			writeFile(|project://Ogol/input/octagon.out.js|, canvas2js(result));
			return;
		} 
	}
}