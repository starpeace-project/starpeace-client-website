
export default class Sprite
  constructor: (@_width, @_height) ->

  within_canvas: (canvas_x, canvas_y, viewport) ->
    x_min = canvas_x - (@_width - viewport.tile_width) * .5
    x_max = x_min + @_width
    y_min = canvas_y - (@_height - viewport.tile_height)
    y_max = y_min + @_height

    (x_min <= viewport.canvas_width || x_max >= 0) && (y_min <= viewport.canvas_height || y_max >= 0)

  render: (tile_info, counter, canvas_x, canvas_y, tile_width, tile_height) ->
    @render_sprite(tile_info, canvas_x, canvas_y, tile_width, tile_height)
    @increment_counter(tile_info, counter)

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    # overriden by children

  increment_counter: (tile_info, counter) ->
    # overriden by children
