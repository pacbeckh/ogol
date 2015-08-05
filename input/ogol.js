function render() {
var c = document.getElementById("myCanvas");
var ctx = c.getContext("2d");
ctx.beginPath();
ctx.moveTo(250, 250);
ctx.lineTo(260, 260);
ctx.moveTo(280, 290);
ctx.lineTo(350, 360);
ctx.stroke();
}