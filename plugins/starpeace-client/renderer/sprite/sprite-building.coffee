
###
global PIXI
###

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteBuilding extends Sprite
  constructor: (width, height, @sprite) ->
    super(width, height)

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    @sprite.visible = true
    @sprite.x = canvas_x - (@_width - tile_width) * .5
    @sprite.y = canvas_y - (@_height - tile_height)
    @sprite.width = @_width + 1
    @sprite.height = @_height + 1

  increment_counter: (tile_info, counter) ->
    if @sprite instanceof PIXI.extras.AnimatedSprite
      counter.building.animated += 1
    else
      counter.building.static += 1
