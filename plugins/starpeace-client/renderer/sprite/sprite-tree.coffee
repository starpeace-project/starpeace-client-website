
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteTree extends Sprite
  @BUFFER_X: .5
  @BUFFER_Y: .5

  constructor: (@texture, @has_data) ->
    super()

  width: (viewport) -> viewport.tile_width + SpriteTree.BUFFER_X
  height: (viewport) -> Math.ceil(@texture.height * (viewport.tile_width / @texture.width)) + SpriteTree.BUFFER_Y

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)

    sprite.visible = true
    sprite.alpha = 1
    sprite.x = canvas.x - (width - viewport.tile_width)
    sprite.y = canvas.y - (height - viewport.tile_height)
    sprite.width = width
    sprite.height = height
    sprite.tint = if @has_data then 0xFFFFFF else 0x555555
    sprite.zOrder = -1 * (canvas.y - .5 * viewport.tile_height)
