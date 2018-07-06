
###
global PIXI
###

import PlanetTypeManifest from '~/plugins/starpeace-client/metadata/planet-type-manifest.coffee'

import LayerBuildings from '~/plugins/starpeace-client/renderer/map/layer-buildings.coffee'
import LayerGround from '~/plugins/starpeace-client/renderer/map/layer-ground.coffee'
import LayerOverlay from '~/plugins/starpeace-client/renderer/map/layer-overlay.coffee'
import LayerTree from '~/plugins/starpeace-client/renderer/map/layer-tree.coffee'
import MapSprite from '~/plugins/starpeace-client/renderer/map/map-sprite.coffee'

import Utils from '~/plugins/starpeace-client/renderer/utils.coffee'

export default class Layers
  constructor: (@client, @renderer, @game_state, @ui_state) ->
    @needs_refresh = false

    @ground_layer = new LayerGround(@renderer, @game_state)
    @tree_layer = new LayerTree(@renderer, @game_state)
    @underlay_layer = new LayerOverlay(@renderer, @game_state, true)
    @building_layer = new LayerBuildings(@client, @renderer, @game_state)
    @overlay_layer = new LayerOverlay(@renderer, @game_state, false)

    @last_scale_rendered = 0
    @last_season_rendered = null
    @last_rendered_zones = false
    @last_rendered_overlay = false
    @last_rendered_overlay_type = null

    @refresh()

  destroy: () ->
    layer.destroy() for layer in [@ground_layer, @tree_layer, @underlay_layer, @building_layer, @overlay_layer]

  remove_layers: (stage) ->
    stage.removeChild(@ground_layer.container)
    stage.removeChild(@tree_layer.container)
    stage.removeChild(@underlay_layer.container)
    stage.removeChild(container) for container in @building_layer.containers()
    stage.removeChild(@overlay_layer.container)

  add_layers: (stage) ->
    stage.addChild(@ground_layer.container)
    stage.addChild(@tree_layer.container)
    stage.addChild(@underlay_layer.container)
    stage.addChild(container) for container in @building_layer.containers()
    stage.addChild(@overlay_layer.container)

  should_refresh: () ->
    @needs_refresh || @game_state.game_scale != @last_scale_rendered || @game_state.current_season != @last_season_rendered ||
      @ui_state.show_zones != @last_rendered_zones || @ui_state.show_overlay != @last_rendered_overlay || @ui_state.current_overlay.type != @last_rendered_overlay_type

  info_for_tile: (x, y) ->
    building_chunk_info = @game_state.game_map.building_chunk_info_at(x, y)
    @game_state.game_map.update_building_chunk_at(x, y) unless building_chunk_info?.is_current()

    has_ground = false
    has_tree = false
    zone_info = null
    building_info = null
    overlay_info = null

    if building_chunk_info?
      if @ui_state.show_zones
        zone_chunk_info = @game_state.game_map.zone_chunk_info_at(x, y)
        if zone_chunk_info?.is_current()
          zone_info = @game_state.game_map.zone_at(x, y)
        else
          @game_state.game_map.update_zone_chunk_at(x, y)
      else if @ui_state.show_overlay
        overlay_chunk_info = @game_state.game_map.overlay_chunk_info_at(@ui_state.current_overlay.type, x, y)
        if overlay_chunk_info?.is_current()
          overlay_info = @game_state.game_map.overlay_at(@ui_state.current_overlay.type, x, y)
        else
          @game_state.game_map.update_overlay_chunk_at(@ui_state.current_overlay.type, x, y)

      building_info = @game_state.game_map.building_at(x, y)

    if !building_info? && @game_state.game_map.ground_map.has_tree_at(y, x)
      has_tree = true
    else if @game_state.game_map.ground_map.has_ground_at(y, x)
      has_ground = true

    {
      has_building_chunk_info: building_chunk_info?
      has_ground
      has_tree
      zone_info
      building_info
      overlay_info
    }

  refresh: () ->
    @needs_refresh = false
    @last_scale_rendered = @game_state.game_scale
    @last_season_rendered = @game_state.current_season
    @last_rendered_zones = @ui_state.show_zones
    @last_rendered_overlay = @ui_state.show_overlay
    @last_rendered_overlay_type = @ui_state.current_overlay.type

    map_width = @game_state.game_map.width
    map_height = @game_state.game_map.height

    canvas_width = Math.ceil(@renderer.renderer_width || 0)
    canvas_height = Math.ceil(@renderer.renderer_height || 0)
    half_canvas_width = Math.ceil(canvas_width * 0.5)
    half_canvas_height = Math.ceil(canvas_height * 0.5)

    tile_width = Math.ceil(PlanetTypeManifest.DEFAULT_TILE_WIDTH * @game_state.game_scale)
    tile_height = Math.ceil(PlanetTypeManifest.DEFAULT_TILE_HEIGHT * @game_state.game_scale)
    half_tile_width = Math.ceil(tile_width / 2)
    half_tile_height = Math.ceil(tile_height / 2)

    width_in_tiles = Math.ceil(canvas_width / tile_width) + 4
    fixed_y = half_tile_height * width_in_tiles
    fixed_bottom_y = tile_height * map_width - canvas_height - fixed_y

    offset = Math.ceil(Math.sqrt(half_canvas_width * half_canvas_width + half_canvas_height * half_canvas_height))
    omega = Math.atan2(canvas_width / 4, canvas_height / 4)

    view_y = Math.floor(@game_state.game_scale * @game_state.view_offset_y) - (offset * Math.cos(omega))
    view_x = Math.floor(@game_state.game_scale * @game_state.view_offset_x) - (offset * Math.sin(omega))

    i_start = Utils.iso_to_i(half_tile_height, half_tile_width, view_x, view_y)
    j_start = Utils.iso_to_j(half_tile_height, half_tile_width, view_x, view_y)
    i_max = Utils.iso_to_i(half_tile_height, half_tile_width, view_x + canvas_width, view_y + canvas_height) + 2
    j_max = Utils.iso_to_j(half_tile_height, half_tile_width, view_x, view_y + canvas_height) + 2
    j_min = Utils.iso_to_j(half_tile_height, half_tile_width, view_x + canvas_width, view_y)

    n_bump = false
    m_bump = false
    n = 0
    n_buffer = 4
    m = 1
    m_buffer = 6

    sprite_counter = {}
    layer.reset_counter(sprite_counter) for layer in [@ground_layer, @tree_layer, @underlay_layer, @building_layer, @overlay_layer]
    x = i_start
    while x < i_max
      j = j_start - n
      while j < (j_start + m)

        if j > 0 && j < map_height && x > 0 && x < map_width
          canvas_x = (x - j) * half_tile_width - view_x - tile_width
          canvas_y = (x + j) * half_tile_height - view_y - tile_height

          tile_info = @info_for_tile(x, j)
          building_metadata = if tile_info.building_info? then @client.building_manager.building_metadata.buildings[tile_info.building_info.key] else null

          ground_sprite = if tile_info.has_ground then new MapSprite(@ground_layer, @ground_layer.sprite_for(sprite_counter, x, j), tile_width, tile_height) else null
          tree_sprite = if tile_info.has_tree then new MapSprite(@tree_layer, @tree_layer.sprite_for(sprite_counter, x, j), tile_width, -1) else null
          underlay_sprite = if tile_info.zone_info? then new MapSprite(@underlay_layer, @underlay_layer.sprite_for(tile_info.zone_info.color, sprite_counter, x, j), tile_width, tile_height) else null
          building_sprite = if tile_info.building_info? && tile_info.building_info.x == x && tile_info.building_info.y == j then new MapSprite(@building_layer, @building_layer.sprite_for(tile_info.building_info, sprite_counter, x, j), building_metadata.w * tile_width, -1) else null
          overlay_sprite = if tile_info.overlay_info? then new MapSprite(@overlay_layer, @overlay_layer.sprite_for(tile_info.overlay_info.color, sprite_counter, x, j), tile_width, tile_height) else null

          tree_sprite.render(tile_info, sprite_counter, @game_state.game_scale, canvas_x, canvas_y, tile_width, tile_height) if tree_sprite?.should_render(@game_state.game_scale, canvas_x, canvas_y, canvas_width, canvas_height)
          ground_sprite.render(tile_info, sprite_counter, @game_state.game_scale, canvas_x, canvas_y, tile_width, tile_height) if ground_sprite?.should_render(@game_state.game_scale, canvas_x, canvas_y, canvas_width, canvas_height)
          underlay_sprite.render(tile_info, sprite_counter, @game_state.game_scale, canvas_x, canvas_y, tile_width, tile_height) if underlay_sprite?.should_render(@game_state.game_scale, canvas_x, canvas_y, canvas_width, canvas_height)
          building_sprite.render(tile_info, sprite_counter, @game_state.game_scale, canvas_x, canvas_y, building_metadata.w * tile_width, (building_metadata.h - 1) * tile_height) if building_sprite?.should_render(@game_state.game_scale, canvas_x, canvas_y, canvas_width, canvas_height)
          overlay_sprite.render(tile_info, sprite_counter, @game_state.game_scale, canvas_x, canvas_y, tile_width, tile_height) if overlay_sprite?.should_render(@game_state.game_scale, canvas_x, canvas_y, canvas_width, canvas_height)

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

    layer.hide_sprites(sprite_counter) for layer in [@ground_layer, @tree_layer, @underlay_layer, @building_layer, @overlay_layer]
