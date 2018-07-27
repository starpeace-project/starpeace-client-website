
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

export default class SpriteTree extends Sprite
  constructor: (width, height, @sprite) ->
    super(width, height)

  render_sprite: (tile_info, canvas_x, canvas_y, tile_width, tile_height) ->
    @sprite.visible = true
    @sprite.x = canvas_x - (@_width - tile_width)
    @sprite.y = canvas_y - (@_height - tile_height)
    @sprite.width = @_width + 1
    @sprite.height = @_height + 1
    @sprite.tint = if tile_info.has_building_chunk_info then 0xFFFFFF else 0x555555
    @sprite.zOrder = -(@sprite.y + @sprite.height - .5 * tile_height)

  increment_counter: (tile_info, counter) ->
    counter.tree += 1
