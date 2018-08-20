
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteRoad extends Sprite
  constructor: (@texture, @is_bridge, @is_on_platform) ->
    super()

  width: (viewport) -> viewport.tile_width + 1
  height: (viewport) -> if @is_bridge then Math.ceil(@texture.height * (viewport.tile_width / @texture.width)) else viewport.tile_height + 1

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)
    offset_y = if @is_on_platform then Math.round(viewport.tile_size_y(.375)) else 0 #.5625

    sprite.visible = true
    sprite.x = canvas.x - (width - viewport.tile_width)
    sprite.y = canvas.y - (height - viewport.tile_height) - offset_y
    sprite.width = width
    sprite.height = height
    sprite.tint = 0xFFFFFF
    sprite.zOrder = -1 * (canvas.y - .5 * viewport.tile_height) - (if @is_on_platform || @is_bridge then viewport.tile_height else 0)
