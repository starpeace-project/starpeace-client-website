
###
global PIXI
###

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteEffect extends Sprite
  constructor: (width, height, @sprite, @parent_x, @parent_y, @x_offset, @y_offset) ->
    super(width, height)

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    @sprite.visible = true
    @sprite.x = canvas_x + @parent_x - @x_offset
    @sprite.y = canvas_y + @parent_y - @y_offset
    @sprite.width = @_width + 1
    @sprite.height = @_height + 1

  increment_counter: (tile_info, counter) ->
    counter.building.effect += 1
