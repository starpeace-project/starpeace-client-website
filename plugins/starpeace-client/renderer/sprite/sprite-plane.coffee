
###
global PIXI
###

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpritePlane extends Sprite
  constructor: (width, height, @sprite, @plane_info, @direction, @velocity, @source_map_x, @source_map_y, @target_map_x, @target_map_y) ->
    super(width, height)

    @last_shown = -1

    @current_map_x = @source_map_x
    @current_map_y = @source_map_y

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    # nothing to do for planes

  increment_counter: (tile_info, counter) ->
    # nothing to do for planes

  is_at_target: () ->
    diff_x = @current_map_x - @target_map_x
    diff_y = @current_map_y - @target_map_y

    return diff_x >= 0 && diff_y >= 0 if @direction == 'se'
    return diff_x <= 0 && diff_y <= 0 if @direction == 'nw'

    return diff_x <= 0 && diff_y >= 0 if @direction == 'sw'
    return diff_x <= 0 && diff_y <= 0 if @direction == 'ne'

    return diff_x >= 0 && diff_y <= 0 if @direction == 'e'
    return diff_x <= 0 && diff_y <= 0 if @direction == 'n'

    return diff_x >= 0 && diff_y >= 0 if @direction == 's'
    return diff_x <= 0 && diff_y >= 0 if @direction == 'w'

    false
