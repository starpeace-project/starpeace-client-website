
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteOverlay extends Sprite
  constructor: (@texture, @color_tint) ->
    super()

  width: (viewport) -> viewport.tile_width - 0.5
  height: (viewport) -> viewport.tile_height - 0.5

  render: (sprite, parent_zorder, oversized_parent, canvas, viewport) ->
    width = @width(viewport) + if oversized_parent then 1 else 0
    height = @height(viewport) + if oversized_parent then 1 else 0

    sprite.visible = true
    sprite.alpha = 0.5
    sprite.x = canvas.x - (width - viewport.tile_width) * .5
    sprite.y = canvas.y - (height - viewport.tile_height)
    sprite.width = width
    sprite.height = height
    sprite.tint = @color_tint
    sprite.zOrder = (parent_zorder - viewport.tile_height) if parent_zorder?
