
import BuildingZone from '~/plugins/starpeace-client/overlay/building-zone.coffee'

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteBuildingFootprint extends Sprite
  constructor: (@texture, @metadata, @zone_color) ->
    super()

  width: (viewport) -> @metadata.w * viewport.tile_width - 0.25
  height: (viewport) -> Math.ceil(@texture.height * (@width(viewport) / @texture.width)) - 0.25

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)

    sprite.visible = true
    sprite.alpha = 1
    sprite.x = canvas.x - (width - viewport.tile_width) * .5
    sprite.y = canvas.y - (height - viewport.tile_height)
    sprite.width = width
    sprite.height = height
    sprite.tint = BuildingZone.TYPES[@metadata.zone]?.color || BuildingZone.TYPES.RESERVED.color
