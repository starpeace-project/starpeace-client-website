
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteBuildingFootprint extends Sprite
  constructor: (width, height, @sprite) ->
    super(width, height)

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    @sprite.visible = true
    @sprite.alpha = 1
    @sprite.x = canvas_x - (@_width - tile_width) * .5
    @sprite.y = canvas_y - (@_height - tile_height)
    @sprite.width = @_width - 0.25
    @sprite.height = @_height - 0.25

  increment_counter: (tile_info, counter) ->
    counter.building_footprint += 1
