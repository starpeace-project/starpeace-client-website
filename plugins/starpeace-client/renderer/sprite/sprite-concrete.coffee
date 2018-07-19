
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteConcrete extends Sprite
  constructor: (width, height, @sprite, @use_building_layer) ->
    super(width, height)

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    @sprite.visible = true
    @sprite.x = canvas_x - (@_width - tile_width)
    @sprite.y = canvas_y - (@_height - tile_height)
    @sprite.width = @_width + 1
    @sprite.height = @_height + 1

  increment_counter: (tile_info, counter) ->
    if @use_building_layer
      counter.building.static += 1
    else
      counter.concrete += 1