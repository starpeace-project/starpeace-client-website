

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.map ||= {}
window.starpeace.renderer.map.MapLayers = class MapLayers

  constructor: (@renderer, @game_state) ->
    @needs_refresh = false

    @ground_layer = new starpeace.renderer.map.LayerGround(@renderer, @game_state)
    @tree_layer = new starpeace.renderer.map.LayerTree(@renderer, @game_state)

    @refresh()

  remove_layers: (stage) ->
    stage.removeChild(@ground_layer.container)
    stage.removeChild(@tree_layer.container)

  add_layers: (stage) ->
    stage.addChild(@ground_layer.container)
    stage.addChild(@tree_layer.container)

  sprite_at: (indices, x, y) ->
    if @game_state.game_map.has_tree_at(y, x)
      { type: 'tree', sprite: @tree_layer.sprite_for(indices.tree, x, y) }
    else if @game_state.game_map.has_ground_at(y, x)
      { type: 'ground', sprite: @ground_layer.sprite_for(indices.ground, x, y) }
    else
      null

  refresh: () ->
    @needs_refresh = false

    scale = new PIXI.Point(@game_state.game_scale, @game_state.game_scale)

    map_width = @game_state.game_map.width
    map_height = @game_state.game_map.height

    canvas_width = Math.ceil(@renderer.renderer_width || 0)
    canvas_height = Math.ceil(@renderer.renderer_height || 0)

    tile_width = Math.ceil(starpeace.metadata.GroundManifest.DEFAULT_TILE_WIDTH * @game_state.game_scale)
    tile_height = Math.ceil(starpeace.metadata.GroundManifest.DEFAULT_TILE_HEIGHT * @game_state.game_scale)
    half_tile_width = Math.ceil(tile_width / 2)
    half_tile_height = Math.ceil(tile_height / 2)

    width_in_tiles = Math.ceil(canvas_width / tile_width) + 4
    fixed_y = half_tile_height * width_in_tiles
    fixed_bottom_y = tile_height * map_width - canvas_height - fixed_y

    initial_y = @game_state.view_offset_y
    view_y = @game_state.view_offset_y #Math.round(Math.min(fixed_bottom_y, Math.max(fixed_y, initial_y)))

    C = 2 * tile_height
    initial_x = @game_state.view_offset_x

    min_x = Math.ceil(-4.0 / 2.0 * view_y + 4.0 / 2.0 * C)
    max_x = Math.ceil(4.0 / 2.0 * view_y - 4.0 / 2.0 * C) - canvas_width
    view_x = @game_state.view_offset_x #Math.round(Math.min(max_x, Math.max(min_x, initial_x)))

#     console.log "(#{min_x} to #{max_x}) #{view_x}  #{view_y}"

    i_start = starpeace.renderer.Utils.iso_to_i(half_tile_height, half_tile_width, view_x, view_y)
    j_start = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x, view_y)
    i_max = starpeace.renderer.Utils.iso_to_i(half_tile_height, half_tile_width, view_x + canvas_width, view_y + canvas_height) + 2
    j_max = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x, view_y + canvas_height) + 2
    j_min = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x + canvas_width, view_y)

    n_bump = false
    m_bump = false
    n = 0
    n_buffer = 4
    m = 1
    m_buffer = 1

    sprite_indices = { tree: 0, ground: 0 }
    x = i_start
    while x < i_max
      j = j_start - n
      while j < (j_start + m)

        if j > 0 && j < map_height && x > 0 && x < map_width
          canvas_x = (x - j) * half_tile_width - view_x - 1 - tile_width
          canvas_y = (x + j) * half_tile_height - view_y - tile_height

          sprite_info = @sprite_at(sprite_indices, x, j)
          if sprite_info?.sprite? &&
              canvas_x >= -sprite_info.sprite.width && (canvas_x < canvas_width + sprite_info.sprite.width) &&
              canvas_y >= -sprite_info.sprite.height && (canvas_y < canvas_height + sprite_info.sprite.height)
            sprite_info.sprite.visible = true
            sprite_info.sprite.x = canvas_x
            sprite_info.sprite.y = canvas_y - (@game_state.game_scale * sprite_info.sprite.texture.height - tile_height)
            sprite_info.sprite.scale = scale
            sprite_indices[sprite_info.type] += 1


        j += 1

      unless n_bump
        n += 1
        n_bump = ((j_start - n) == j_min)
        n += 1 if n_bump
      else
        if n_buffer > 0
          n_buffer -= 1
        else
          n -= 1

      unless m_bump
        m += 1
        m_bump = ((j_start + m) == j_max)
      else
        if m_buffer > 0
          m_buffer -= 1
        else
          m -= 1

      x += 1

    @ground_layer.hide_sprites(sprite_indices.ground)
    @tree_layer.hide_sprites(sprite_indices.tree)


