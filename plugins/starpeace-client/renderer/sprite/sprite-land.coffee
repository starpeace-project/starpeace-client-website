
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteLand extends Sprite
  constructor: (@texture, @has_data) ->
    super()

  width: (viewport) -> viewport.tile_width + 1
  height: (viewport) -> viewport.tile_height + 1

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)

    sprite.visible = true
    sprite.x = canvas.x - (width - viewport.tile_width)
    sprite.y = canvas.y - (height - viewport.tile_height)
    sprite.width = width + 1
    sprite.height = height + 1
    sprite.tint = if @has_data then 0xFFFFFF else 0x555555
