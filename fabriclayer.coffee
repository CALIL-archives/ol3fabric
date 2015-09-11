class FabricLayer extends ol.layer.Vector
  map: null
  constructor: (options) ->
    super(options)
    @on 'postcompose', @postcompose_, @
    @setSource(new ol.source.Vector())

  postcompose_: (event)->
    if not @map?
      return
#    console.log event.frameState.focus
#    console.log ol.proj.transform(event.frameState.focus, 'EPSG:3857', 'EPSG:4326');
    context = event.context
    pixelRatio = event.frameState.pixelRatio

    view = @map.getView()
    resolutionAtCoords = view.getProjection().getPointResolution(event.frameState.viewState.resolution, view.getCenter())
    oneMeterPx = (1 / resolutionAtCoords) * pixelRatio

    r = event.frameState.viewState.rotation
    r2 = @rotation * Math.PI / 180


    if not window.canvas?
      fabricInit(context, @)

    # 1px = 1m
#    canvas.setZoom(oneMeterPx)
    canvas.zoomToPoint(new fabric.Point(canvas.width/2, canvas.height/2), oneMeterPx)
    canvas.renderAllOnTop()


fabricInit = (context, layer)=>
  window.canvas = new fabric.Canvas(context.canvas,
    width: context.canvas.width
    height: context.canvas.height
    renderOnAddRemove: true
  )

  window.onresize = ->
    canvas.setWidth(document.documentElement.clientWidth)
    canvas.setHeight(document.documentElement.clientHeight)

  # common setting for fabric Object
  fabric.Object.prototype.scaleX = 1
  fabric.Object.prototype.scaleY = 1
  fabric.Object.prototype.originX = 'center'
  fabric.Object.prototype.originY = 'center'
  fabric.Object.prototype.transparentCorners = true
  fabric.Object.prototype.cornerColor = "#488BD4"
  fabric.Object.prototype.borderOpacityWhenMoving = 0.8
  fabric.Object.prototype.cornerSize = 10


  canvas._renderAll = canvas.renderAll
  canvas.renderAll = ->
    layer.changed()
  canvas._renderTop = canvas.renderTop
  canvas.renderTop = =>
    layer.changed()

  # fix allOneTop mode
  canvas.renderAllOnTop = ->
    canvasToDrawOn = this.contextTop
    activeGroup = this.getActiveGroup()

    this.clearContext(this.contextTop)

    this.fire('before:render')

    if this.clipTo
      fabric.util.clipContext(this, canvasToDrawOn)

    this._renderBackground(canvasToDrawOn)
    this._renderObjects(canvasToDrawOn, activeGroup)
    this._renderActiveGroup(canvasToDrawOn, activeGroup)


    # we render the top context - last object
    if this.selection and this._groupSelector
      this._drawSelection()

    if this.clipTo
      canvasToDrawOn.restore()

    this._renderOverlay(canvasToDrawOn);

    if this.controlsAboveOverlay && this.interactive
      this.drawControls(canvasToDrawOn)

    this.fire('after:render');

    return this;

  red = new fabric.Rect({
    left: canvas.width/2 - 1,
    top: canvas.height/2,
    fill: 'red',
    width: 4,
    height: 4,
    angle: 45
  });
  blue = new fabric.Rect({
    left: canvas.width/2 + 1,
    top: canvas.height/2,
    fill: 'blue',
    width: 4,
    height: 4,
    angle: 45
  });

  canvas.add(red)
  canvas.add(blue)
