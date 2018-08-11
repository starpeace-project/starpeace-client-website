
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteRoad extends Sprite
  constructor: (@texture) ->
    super()

  width: (viewport) -> viewport.tile_width + 1
  height: (viewport) -> viewport.tile_height + 1

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)

    sprite.visible = true
    sprite.x = canvas.x - (width - viewport.tile_width)
    sprite.y = canvas.y - (height - viewport.tile_height)
    sprite.width = width
    sprite.height = height
