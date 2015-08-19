module ogol::Canvas

alias Point = tuple[real x, real y];

alias Canvas = list[Shape];

data Shape
  = line(Point from, Point to)
  ;
  
