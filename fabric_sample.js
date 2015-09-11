// Generated by CoffeeScript 1.9.3
window.onload = function() {
  var blue, map, red;
  map = document.getElementById('map');
  window.canvas = new fabric.Canvas(map, {
    width: document.documentElement.clientWidth,
    height: document.documentElement.clientHeight,
    renderOnAddRemove: true
  });
  window.onresize = function() {
    canvas.setWidth(document.documentElement.clientWidth);
    return canvas.setHeight(document.documentElement.clientHeight);
  };
  canvas._renderAll = canvas.renderAll;
  canvas.renderAll = (function(_this) {
    return function() {
      return canvas._renderAll(true);
    };
  })(this);
  red = new fabric.Rect({
    left: canvas.width / 2 - 100,
    top: 100,
    fill: 'red',
    width: 400,
    height: 400,
    angle: 45
  });
  blue = new fabric.Rect({
    left: canvas.width / 2 + 100,
    top: 100,
    fill: 'blue',
    width: 400,
    height: 400,
    angle: 45
  });
  canvas.add(red);
  return canvas.add(blue);
};

//# sourceMappingURL=fabric_sample.js.map
