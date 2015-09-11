window.onload = ->
  map = document.getElementById('map')
  window.canvas = new fabric.Canvas(map,
    width: document.documentElement.clientWidth
    height: document.documentElement.clientHeight
    renderOnAddRemove: true
  )

  window.onresize = ->
    canvas.setWidth(document.documentElement.clientWidth)
    canvas.setHeight(document.documentElement.clientHeight)

  # renderAll allOnTop mode bug
  canvas._renderAll = canvas.renderAll
  canvas.renderAll = =>
    canvas._renderAll(true)

  red = new fabric.Rect({
    left: canvas.width/2 - 100,
    top: 100,
    fill: 'red',
    width: 400,
    height: 400,
    angle: 45
  });
  blue = new fabric.Rect({
    left: canvas.width/2 + 100,
    top: 100,
    fill: 'blue',
    width: 400,
    height: 400,
    angle: 45
  });

  canvas.add(red)
  canvas.add(blue)
