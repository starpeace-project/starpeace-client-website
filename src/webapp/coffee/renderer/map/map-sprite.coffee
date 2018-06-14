

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.map ||= {}
window.starpeace.renderer.map.MapSprite = class MapSprite

  constructor: (@type, @sprite) ->

  width: (scale_x) ->
    Math.ceil(scale_x * (@sprite?.texture?.width || 0))

  height: (scale_y) ->
    Math.ceil(scale_y * (@sprite?.texture?.height || 0))

  within_canvas: (scale, canvas_x, canvas_y, canvas_width, canvas_height) ->
    width = @width(scale)
    height = @height(scale)

    within = canvas_x >= (-2 * width) && (canvas_x < canvas_width + width) &&
      canvas_y >= (-2 * height) && (canvas_y < canvas_height + height)

    canvas_x >= -width && (canvas_x < canvas_width + width) &&
      canvas_y >= -height && (canvas_y < canvas_height + height)
