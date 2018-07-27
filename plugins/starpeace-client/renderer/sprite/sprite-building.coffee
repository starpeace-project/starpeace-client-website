
###
global PIXI
###

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteBuilding extends Sprite
  constructor: (width, height, @sprite, @effect_sprites) ->
    super(width, height)

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    @sprite.visible = true
    @sprite.x = canvas_x - (@_width - tile_width) * .5
    @sprite.y = canvas_y - (@_height - tile_height)
    @sprite.width = @_width + 1
    @sprite.height = @_height + 1
    @sprite.zOrder = -(@sprite.y + @sprite.height - @sprite.map_half_height)

    for sprite in @effect_sprites
      sprite.render_sprite(tile_info, @sprite.x, @sprite.y, tile_width, tile_height)
      sprite.sprite.zOrder = @sprite.zOrder - 1

  increment_counter: (tile_info, counter) ->
    if @sprite instanceof PIXI.extras.AnimatedSprite
      counter.building.animated += 1
    else
      counter.building.static += 1

    sprite.increment_counter(tile_info, counter) for sprite in @effect_sprites
