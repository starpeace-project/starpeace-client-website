###
* helper class to provide abstraction for camera
###

class CameraManager

  constructor: (@client, @renderer) ->

  adjust_scale: (delta) ->
    # before_scale = @client.game_state.game_scale
    @client.game_state.game_scale -= delta
    @client.game_state.game_scale = 1.5 if @client.game_state.game_scale > 1.5
    @client.game_state.game_scale = 0.5 if @client.game_state.game_scale < 0.5

    @client.renderer.viewport().refresh()

    # delta_change = @client.game_state.game_scale - before_scale
    # @renderer.initialize_map() if delta_change != 0 && @renderer.initialized

  zoom_in: () ->
    @renderer.initialized && @adjust_scale(-0.25) != 0

  zoom_out: () ->
    @renderer.initialized && @adjust_scale(0.25) != 0

  pan_camera: (delta_x, delta_y) ->
    return false unless @renderer.initialized
    @client.game_state.view_offset_x += delta_x unless delta_x == 0
    @client.game_state.view_offset_y += delta_y unless delta_y == 0

    @renderer.layers.needs_refresh = true if @renderer.layers? && (delta_x != 0 || delta_y != 0)

export default CameraManager
