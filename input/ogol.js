function render() {
  var c = document.getElementById("myCanvas");
  var ctx = c.getContext("2d");
  ctx.beginPath();
  ctx.moveTo(250.0, 250.0);
  ctx.lineTo(250.0, 200.0);
  ctx.moveTo(250.0, 200.0);
  ctx.lineTo(350.00000000000, 200.00000000000);
  ctx.stroke();
}