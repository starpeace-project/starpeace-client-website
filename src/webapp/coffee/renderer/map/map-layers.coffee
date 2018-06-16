

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.map ||= {}
window.starpeace.renderer.map.MapLayers = class MapLayers

  constructor: (@renderer, @game_state, @ui_state) ->
    @needs_refresh = false

    @ground_layer = new starpeace.renderer.map.LayerGround(@renderer, @game_state)
    @tree_layer = new starpeace.renderer.map.LayerTree(@renderer, @game_state)
    @overlay_layer = new starpeace.renderer.map.LayerOverlay(@renderer, @game_state)

    @last_season_rendered = null
    @last_rendered_zones = false

    @refresh()

  remove_layers: (stage) ->
    stage.removeChild(@ground_layer.container)
    stage.removeChild(@tree_layer.container)
    stage.removeChild(@overlay_layer.container)

  add_layers: (stage) ->
    stage.addChild(@ground_layer.container)
    stage.addChild(@tree_layer.container)
    stage.addChild(@overlay_layer.container)

  sprite_at: (indices, x, y) ->
    if @game_state.game_map.ground_map.has_tree_at(y, x)
      new starpeace.renderer.map.MapSprite('tree', @tree_layer.sprite_for(indices.tree, x, y))
    else if @game_state.game_map.ground_map.has_ground_at(y, x)
      new starpeace.renderer.map.MapSprite('ground', @ground_layer.sprite_for(indices.ground, x, y))
    else
      null

  should_refresh: () ->
    @needs_refresh || @game_state.current_season != @last_season_rendered || @ui_state.show_zones != @last_rendered_zones

  refresh: () ->
    @needs_refresh = false
    @last_season_rendered = @game_state.current_season
    @last_rendered_zones = @ui_state.show_zones

    map_width = @game_state.game_map.width
    map_height = @game_state.game_map.height

    canvas_width = Math.ceil(@renderer.renderer_width || 0)
    canvas_height = Math.ceil(@renderer.renderer_height || 0)
    half_canvas_width = Math.ceil(canvas_width * 0.5)
    half_canvas_height = Math.ceil(canvas_height * 0.5)

    tile_width = Math.ceil(starpeace.metadata.PlanetTypeManifest.DEFAULT_TILE_WIDTH * @game_state.game_scale)
    tile_height = Math.ceil(starpeace.metadata.PlanetTypeManifest.DEFAULT_TILE_HEIGHT * @game_state.game_scale)
    half_tile_width = Math.ceil(tile_width / 2)
    half_tile_height = Math.ceil(tile_height / 2)

    width_in_tiles = Math.ceil(canvas_width / tile_width) + 4
    fixed_y = half_tile_height * width_in_tiles
    fixed_bottom_y = tile_height * map_width - canvas_height - fixed_y

    offset = Math.ceil(Math.sqrt(half_canvas_width * half_canvas_width + half_canvas_height * half_canvas_height))
    omega = Math.atan2(canvas_width / 4, canvas_height / 4)

    view_y = Math.floor(@game_state.game_scale * @game_state.view_offset_y) - (offset * Math.cos(omega))
    view_x = Math.floor(@game_state.game_scale * @game_state.view_offset_x) - (offset * Math.sin(omega))

    i_start = starpeace.renderer.Utils.iso_to_i(half_tile_height, half_tile_width, view_x, view_y)
    j_start = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x, view_y)
    i_max = starpeace.renderer.Utils.iso_to_i(half_tile_height, half_tile_width, view_x + canvas_width, view_y + canvas_height) + 2
    j_max = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x, view_y + canvas_height) + 2
    j_min = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x + canvas_width, view_y)

    #console.log "#{@game_state.view_offset_x} #{@game_state.view_offset_y} -> #{view_x}  #{view_y} -> #{i_start} to #{i_max} and #{j_start} to #{j_min}/#{j_max}"

    n_bump = false
    m_bump = false
    n = 0
    n_buffer = 4
    m = 1
    m_buffer = 1

    sprite_indices = { tree: 0, ground: 0, overlay: 0 }
    x = i_start
    while x < i_max
      j = j_start - n
      while j < (j_start + m)

        if j > 0 && j < map_height && x > 0 && x < map_width
          canvas_x = (x - j) * half_tile_width - view_x - tile_width
          canvas_y = (x + j) * half_tile_height - view_y - tile_height

          building_chunk_info = @game_state.game_map.building_chunk_info_at(x, j)
          @game_state.game_map.update_building_chunk_at(x, j) unless building_chunk_info?.is_current()

          zone_color = null
          if building_chunk_info?
            if @ui_state.show_zones
              zone_chunk_info = @game_state.game_map.zone_chunk_info_at(x, j)
              if zone_chunk_info?.is_current()
                zone_info = @game_state.game_map.zone_at(x, j)
                zone_color = zone_info.color if zone_info?
              else
                @game_state.game_map.update_zone_chunk_at(x, j)

            building_info = @game_state.game_map.building_at(x, j)

          sprite_info = @sprite_at(sprite_indices, x, j)
          if sprite_info?.sprite? && sprite_info.within_canvas(@game_state.game_scale, canvas_x, canvas_y, canvas_width, canvas_height)
            sprite_height = sprite_info.height(@game_state.game_scale)
            sprite_info.sprite.visible = true
            sprite_info.sprite.x = canvas_x
            sprite_info.sprite.y = canvas_y - (sprite_height - tile_height)
            sprite_info.sprite.width = tile_width + 1
            sprite_info.sprite.height = sprite_height + 1
            sprite_info.sprite.tint = if building_chunk_info? then 0xFFFFFF else 0x555555

            if building_chunk_info? && zone_color?
              overlay_sprite = @overlay_layer.sprite_for(sprite_indices.overlay, x, j)
              overlay_sprite.visible = true
              overlay_sprite.alpha = 0.6
              overlay_sprite.x = canvas_x
              overlay_sprite.y = canvas_y
              overlay_sprite.width = tile_width - 0.25
              overlay_sprite.height = tile_height - 0.25
              overlay_sprite.tint = zone_color
              sprite_indices.overlay += 1

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
    @overlay_layer.hide_sprites(sprite_indices.overlay)


