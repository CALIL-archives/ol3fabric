class FabricLayer extends ol.layer.Vector
  map    : null
  context: null
  canvas : null
  geojson: null
  angle  : 0
  constructor: (options) ->
    super(options)
    @on 'postcompose', @postcompose_, @
    @setSource(new ol.source.Vector())
    @geojson = options.geojson
  setAngle: (angle) ->
    @angle = angle
    @changed()
  postcompose_: (event)->
    if not @map?
      return
    @context = event.context
    pixelRatio = event.frameState.pixelRatio

    view = @map.getView()
    resolutionAtCoords = view.getProjection().getPointResolution(event.frameState.viewState.resolution, view.getCenter())
    oneMeterPx = (1 / resolutionAtCoords) * pixelRatio

    r = event.frameState.viewState.rotation
    r2 = @rotation * Math.PI / 180

    # initialize fabric
    if not @canvas?
      @map.on('moveend', =>
        console.log('moveend')
        @addFabricObject()
      )

      @fabricInit()

    # 1px = 1m
#    @canvas.setZoom(oneMeterPx)
#    @canvas.zoomToPoint(new fabric.Point(@canvas.width/2, @canvas.height/2), oneMeterPx)
#    renderFabricObject(@)
    @canvas.renderAllOnTop()

  fabricInit : ()->
    @canvas = new fabric.Canvas(@context.canvas,
      width : @context.canvas.width
      height: @context.canvas.height
      renderOnAddRemove: true
    )

    window.onresize = =>
      @canvas.setWidth(document.documentElement.clientWidth)
      @canvas.setHeight(document.documentElement.clientHeight)

    @canvas.on 'object:modified', ()=>
      console.log('object:modified')
#      fabric.util.object.clone(o);

    # common setting for fabric Object
    fabric.Object.prototype.scaleX = 1
    fabric.Object.prototype.scaleY = 1
#    fabric.Object.prototype.originX = 'center'
#    fabric.Object.prototype.originY = 'center'
    fabric.Object.prototype.transparentCorners = true
    fabric.Object.prototype.cornerColor = "#488BD4"
    fabric.Object.prototype.borderOpacityWhenMoving = 0.8
    fabric.Object.prototype.cornerSize = 10


    @canvas._renderAll = @canvas.renderAll
    @canvas.renderAll = =>
      @changed()
    @canvas._renderTop = @canvas.renderTop
    @canvas.renderTop = =>
      @changed()

    # fix allOneTop mode
    @canvas.renderAllOnTop = ->
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

  addFabricObject : ()->
      # remove fabric all object
      @canvas.clear()

    #  console.log @geojson
    #  console.log @map.getView()
    #  console.log @map.getView().getCenter()
    #  console.log @map.getView().getZoom()

      # create fabric object from geojson
      for feature in @geojson.features
    #    console.log feature
    #    console.log feature.properties
        coordinates = feature.geometry.coordinates[0]
        new_cordinates = []
        for coordinate in coordinates
          c = @map.getPixelFromCoordinate(coordinate)
          new_cordinates.push(x:c[0], y:c[1])
#        x1 = @map.getPixelFromCoordinate(coordinates[1])[0]
#        y1 = @map.getPixelFromCoordinate(coordinates[1])[1]
#        x2 = @map.getPixelFromCoordinate(coordinates[3])[0]
#        y2 = @map.getPixelFromCoordinate(coordinates[3])[1]
#
#        object = new fabric.Rect({
#          left: x1+width/2,
#          top : y1+height/2,
#          fill: feature.properties.color,
#          width:  width,
#          height: height,
#          angle: @angle
#        })
        console.log new_cordinates
        object = new fabric.Polygon new_cordinates,
#            left: 0,
#            top: 0,
            fill: feature.properties.color,
        @canvas.add(object)

  rotationToAngle: (rotation)->
    # rotation 1.57 == 90 angle
    return rotation / 1.57 * 90
