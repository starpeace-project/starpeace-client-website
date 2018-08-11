
export default class Sprite
  within_canvas: (canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)

    x_min = canvas.x - (width - viewport.tile_width) * .5
    x_max = x_min + width
    y_min = canvas.y - (height - viewport.tile_height)
    y_max = y_min + height

    (x_min <= viewport.canvas_width || x_max >= 0) && (y_min <= viewport.canvas_height || y_max >= 0)
