import _ from 'lodash';
import { Polygon } from 'pixi.js'

import CompositePolygon from '~/plugins/pixi/composite-polygon'
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteBuildingConstruction extends Sprite
  constructor: (@textures, @is_animated, @is_valid, @image_metadata) ->
    super()

    @_hit_area = @image_metadata.hit_area || []

  width: (viewport) -> @image_metadata.w * viewport.tile_width + 1
  height: (viewport) -> Math.ceil(@textures[0].height * (@width(viewport) / @textures[0].width)) + 1

  hit_area: (viewport) ->
    return null unless @_hit_area.length
    new CompositePolygon(_.map(@_hit_area, (vertices) -> new Polygon(_.flatten(_.map(vertices, (vertex) -> [ vertex.x, vertex.y ] )))))

  render: (sprite, canvas, viewport) ->
    width = @width(viewport)
    height = @height(viewport)

    sprite.visible = true
    sprite.alpha = 0.7
    sprite.x = canvas.x - (width - viewport.tile_width) * .5
    sprite.y = canvas.y - (height - viewport.tile_height)
    sprite.width = width
    sprite.height = height
    sprite.tint = if @is_valid then 0x00FF00 else 0xFF0000

    sprite.zIndex = sprite.y + sprite.height - Math.round(.5 * @image_metadata.h * viewport.tile_height)
