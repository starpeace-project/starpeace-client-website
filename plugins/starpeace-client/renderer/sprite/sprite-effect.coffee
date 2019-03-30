
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteEffect extends Sprite
  constructor: (@textures, @info, @metadata) ->
    super()

  width: (viewport) -> viewport.with_scale(@textures[0].width) + 1
  height: (viewport) -> viewport.tile_height + 1

  render: (sprite, parent_sprite, canvas, viewport) ->
    parent_x = Math.round(parent_sprite.width * @info.x)
    parent_y = Math.round(parent_sprite.height * @info.y)
    x_offset = Math.floor(viewport.with_scale(@metadata.s_x))
    y_offset = Math.floor(viewport.with_scale(@metadata.s_y))
    width = @width(viewport)
    height = @height(viewport)

    sprite.visible = true
    sprite.alpha = parent_sprite.alpha
    sprite.x = parent_sprite.x + parent_x - x_offset
    sprite.y = parent_sprite.y + parent_y - y_offset
    sprite.width = width
    sprite.height = height
    sprite.tint = 0xFFFFFF
    sprite.zIndex = parent_sprite.zIndex + 1
