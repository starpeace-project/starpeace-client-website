
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteRoad extends Sprite
  constructor: (@texture, @is_bridge, @is_over_water) ->
    super()

  width: (viewport) -> viewport.tile_width + 1
  height: (viewport) -> if @is_bridge then Math.ceil(@texture.height * (viewport.tile_width / @texture.width)) else viewport.tile_height + 1

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)
    offset_y = if !@is_bridge && @is_over_water then Math.round(viewport.tile_size_y(.375)) else 0 #.5625

    sprite.visible = true
    sprite.alpha = 1
    sprite.x = canvas.x - (width - viewport.tile_width)
    sprite.y = canvas.y - (height - viewport.tile_height) - offset_y
    sprite.width = width
    sprite.height = height
    sprite.tint = 0xFFFFFF
    #sprite.zIndex = (canvas.y - .5 * viewport.tile_height)# + (if @is_over_water || @is_bridge then viewport.tile_height else 0)
    sprite.zIndex = sprite.y + sprite.height + offset_y - Math.round(.5 * viewport.tile_height)# - (if @is_platform then .25 * viewport.tile_height else 0)
