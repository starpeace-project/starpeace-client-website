
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteBuilding extends Sprite
  constructor: (@textures, @is_animated, @_hit_area, @metadata, @effects) ->
    super()

  width: (viewport) -> @metadata.w * viewport.tile_width + 1
  height: (viewport) -> Math.ceil(@textures[0].height * (@width(viewport) / @textures[0].width)) + 1

  hit_area: (viewport) ->
    return null unless @_hit_area.length
    new PIXI.CompositePolygon(_.map(@_hit_area, (vertices) -> new PIXI.Polygon(_.flatten(_.map(vertices, (vertex) -> [ vertex.x, vertex.y ] )))))

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)

    sprite.visible = true
    sprite.alpha = 1
    sprite.x = canvas.x - (width - viewport.tile_width) * .5
    sprite.y = canvas.y - (height - viewport.tile_height)
    sprite.width = width
    sprite.height = height
    sprite.tint = 0xFFFFFF

    sprite.zOrder = -1 * (sprite.y + sprite.height - Math.round(.5 * @metadata.h * viewport.tile_height))
