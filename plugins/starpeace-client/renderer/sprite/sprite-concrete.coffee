
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteConcrete extends Sprite
  constructor: (@texture, @is_flat, @is_platform) ->
    super()

  width: (viewport) -> viewport.tile_width + 1
  height: (viewport) -> Math.ceil(@texture.height * (viewport.tile_width / @texture.width)) + 1

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)
    offset_y = if @is_platform then Math.round(viewport.tile_size_y(.1)) else 0

    sprite.visible = true
    sprite.alpha = 1
    sprite.x = canvas.x - (width - viewport.tile_width)
    sprite.y = canvas.y - (height - viewport.tile_height) + offset_y
    sprite.width = width
    sprite.height = height
    sprite.tint = 0xFFFFFF
    sprite.zIndex = (canvas.y - .5 * viewport.tile_height) - (if @is_platform then (if @is_flat then .25 else .5) * viewport.tile_height else 0)
