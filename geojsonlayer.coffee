# geojson
# http://geojson.org/geojson-spec.html

class GeoJSONLayer extends ol.layer.Vector
  geojson: null
  constructor: (options) ->
    super(options)
    @geojson = options.geojson
    @translateGeoJSON()
    return new ol.layer.Vector
      source: @createVectorSource()
      style : @styleFunction
  # translate EPSG:4326 to EPSG:3857
  translateGeoJSON: ->
    for feature in @geojson.features
      new_coordinates = []
      for coordinate in feature.geometry.coordinates[0]
        new_coordinates.push(ol.proj.transform(coordinate, 'EPSG:4326', 'EPSG:3857'))
      feature.geometry.coordinates[0] = new_coordinates
  createVectorSource: (geojson)->
    return new ol.source.Vector
      features: (new ol.format.GeoJSON()).readFeatures(@geojson)
  styleFunction: (feature, resolution) ->
#    @styles[feature.getGeometry().getType()]
    return [
      new ol.style.Style
        stroke: new ol.style.Stroke
          color: feature.getProperties()['color']
          width: 3
        fill: new ol.style.Fill(color: feature.getProperties()['color'])
#        fill: new ol.style.Fill(color: 'rgba(0, 0, 255, 0.1)')
    ]
