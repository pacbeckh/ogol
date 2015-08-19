module ogol::Canvas2JS

import ogol::Canvas;
import IO;

int CANVAS_WIDTH = 500;
int CANVAS_HEIGHT = 500;


void compileCanvas(Canvas cv, loc l) {
  l.file ="ogol";
  l.extension = "js";
  writeFile(l, canvas2js(cv));
}

   
str canvas2js(Canvas cv) =
  "function render() {
  '  var c = document.getElementById(\"myCanvas\");
  '  var ctx = c.getContext(\"2d\");\n"
  + ( "  ctx.beginPath();" | it + "\n  " + shape2js(s) | s <- cv )
  + "\n  ctx.stroke();
  '}";
  
str shape2js(line(<x1, y1>, <x2, y2>))
  = "ctx.moveTo(<adjustX(x1)>, <adjustY(y1)>);
    '  ctx.lineTo(<adjustX(x2)>, <adjustY(y2)>);";
   
real adjustX(real x) = x + (CANVAS_WIDTH / 2);
real adjustY(real y) = y + (CANVAS_HEIGHT / 2);