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
	str file = "/Users/matstijl/development/repositories/github/stil4m/ogol/input/octagon.ogol";
	str fileContent = readFile(|file://<file>|);
	//tree = ;
	//renderParsetree();
	str output = "NO OUTPUT";
	Tree tree = parse(#start[Program], fileContent);
	visit (tree) {
		case /Program p : {
			result = evalProgram(p);
			println(canvas2js(result));
			return;
		} 
	}
}