
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteOverlay extends Sprite
  constructor: (width, height, @sprite, @is_underlay) ->
    super(width, height)

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    @sprite.visible = true
    @sprite.alpha = 0.5
    @sprite.x = canvas_x
    @sprite.y = canvas_y
    @sprite.width = @_width - 0.25
    @sprite.height = @_height - 0.25

  increment_counter: (tile_info, counter) ->
    if @is_underlay
      counter.underlay++
    else
      counter.overlay++
