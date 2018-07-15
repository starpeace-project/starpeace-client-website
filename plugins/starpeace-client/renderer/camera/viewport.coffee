import PlanetTypeManifest from '~/plugins/starpeace-client/metadata/planet-type-manifest.coffee'

export default class Viewport

  constructor: (@game_state, renderer_width, renderer_height) ->
    @canvas_width = Math.ceil(renderer_width || 0)
    @canvas_height = Math.ceil(renderer_height || 0)
    @half_canvas_width = Math.ceil(@canvas_width * 0.5)
    @half_canvas_height = Math.ceil(@canvas_height * 0.5)

    @refresh()

  refresh: () ->
    @tile_width = Math.ceil(PlanetTypeManifest.DEFAULT_TILE_WIDTH * @game_state.game_scale)
    @tile_height = Math.ceil(PlanetTypeManifest.DEFAULT_TILE_HEIGHT * @game_state.game_scale)
    @half_tile_width = Math.ceil(@tile_width / 2)
    @half_tile_height = Math.ceil(@tile_height / 2)

    @offset = Math.ceil(Math.sqrt(@half_canvas_width * @half_canvas_width + @half_canvas_height * @half_canvas_height))
    @omega = Math.atan2(@canvas_width / 4, @canvas_height / 4)

  map_center: () ->
    x = @game_state.game_scale * @game_state.view_offset_x - @offset * Math.sin(@omega)
    y = @game_state.game_scale * @game_state.view_offset_y - @offset * Math.cos(@omega)
    {
      x: Math.round(x)
      y: Math.round(y)
      x_exact: x
      y_exact: y
    }

  map_to_iso: (x, y) ->
    y_ratio = y / @half_tile_height
    x_ratio = x / @half_tile_width
    i = (y_ratio + x_ratio) * 0.5
    j = (y_ratio - x_ratio) * 0.5
    {
      i: Math.round(i)
      j: Math.round(j)
      i_exact: i
      j_exact: j
    }

  iso_to_canvas: (i, j, center) ->
    {
      x: Math.round((i - j) * @half_tile_width - @tile_width - center.x)
      y: Math.round((i + j) * @half_tile_height - @tile_height - center.y)
    }
