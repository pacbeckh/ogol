module ogol::Canvas

alias Point = tuple[int x, int y];

alias Canvas = list[Shape];

data Shape
  = line(Point from, Point to)
  ;
  
