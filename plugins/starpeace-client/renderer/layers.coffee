
###
global PIXI
###

import PlanetTypeManifest from '~/plugins/starpeace-client/metadata/planet-type-manifest.coffee'

import LayerBuilding from '~/plugins/starpeace-client/renderer/layer/layer-building.coffee'
import LayerBuildingFootprint from '~/plugins/starpeace-client/renderer/layer/layer-building-footprint.coffee'
import LayerLand from '~/plugins/starpeace-client/renderer/layer/layer-land.coffee'
import LayerOverlay from '~/plugins/starpeace-client/renderer/layer/layer-overlay.coffee'
import LayerPlane from '~/plugins/starpeace-client/renderer/layer/layer-plane.coffee'
import LayerTree from '~/plugins/starpeace-client/renderer/layer/layer-tree.coffee'
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

import Utils from '~/plugins/starpeace-client/renderer/utils.coffee'

PLANE_CHECK_SPEED = 5000

export default class Layers
  constructor: (@renderer, @building_manager, @effect_manager, @plane_manager, @game_state, @ui_state) ->
    @needs_refresh = false

    @land_layer = new LayerLand(@game_state)
    @tree_layer = new LayerTree(@game_state)
    @underlay_layer = new LayerOverlay(@game_state, true)
    @building_layer = new LayerBuilding(@building_manager, @effect_manager, @game_state, @ui_state)
    @building_footprint_layer = new LayerBuildingFootprint(@building_manager, @game_state)
    @overlay_layer = new LayerOverlay(@game_state, false)
    @plane_layer = new LayerPlane(@plane_manager, @renderer, @game_state, @ui_state)

    @last_scale_rendered = 0
    @last_season_rendered = null
    @last_rendered_zones = false
    @last_rendered_overlay = false
    @last_rendered_overlay_type = null
    @last_rendered_render_options = { trees: null, buildings: null, building_animations: null, building_effects: null, planes: null }

    @check_loop = setInterval((=> @check_planes()), PLANE_CHECK_SPEED)

    @refresh()

  destroy: () ->
    clearInterval(@check_loop) if @check_loop?
    layer.destroy() for layer in [@land_layer, @tree_layer, @underlay_layer, @building_layer, @building_footprint_layer, @overlay_layer, @plane_layer]

  remove_layers: (stage) ->
    stage.removeChild(@building_layer.layer)

    stage.removeChild(@land_layer.container)
    stage.removeChild(@tree_layer.container)
    stage.removeChild(@underlay_layer.container)
    stage.removeChild(@building_layer.container)
    stage.removeChild(@building_footprint_layer.container)
    stage.removeChild(@overlay_layer.container)
    stage.removeChild(@plane_layer.container)

  add_layers: (stage) ->
    stage.addChild(@building_layer.layer)

    stage.addChild(@land_layer.container)
    stage.addChild(@tree_layer.container)
    stage.addChild(@underlay_layer.container)
    stage.addChild(@building_layer.container)
    stage.addChild(@building_footprint_layer.container)
    stage.addChild(@overlay_layer.container)
    stage.addChild(@plane_layer.container)

  should_refresh: () ->
    @needs_refresh || @game_state.game_scale != @last_scale_rendered || @game_state.current_season != @last_season_rendered ||
      @ui_state.show_zones != @last_rendered_zones || @ui_state.show_overlay != @last_rendered_overlay || @ui_state.current_overlay.type != @last_rendered_overlay_type ||
      @ui_state.render_trees != @last_rendered_render_options.trees || @ui_state.render_buildings != @last_rendered_render_options.buildings ||
      @ui_state.render_building_animations != @last_rendered_render_options.building_animations || @ui_state.render_building_effects != @last_rendered_render_options.building_effects ||
      @ui_state.render_planes != @last_rendered_render_options.planes

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

    if @ui_state.render_trees && !building_info? && @game_state.game_map.ground_map.has_tree_at(y, x)
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

    @last_rendered_render_options.trees = @ui_state.render_trees
    @last_rendered_render_options.buildings = @ui_state.render_buildings
    @last_rendered_render_options.building_animations = @ui_state.render_building_animations
    @last_rendered_render_options.building_effects = @ui_state.render_building_effects
    @last_rendered_render_options.planes = @ui_state.render_planes


    map_width = @game_state.game_map.width
    map_height = @game_state.game_map.height

    viewport = @renderer.viewport()

    tile_width = viewport.tile_width
    tile_height = viewport.tile_height

    view_center = viewport.map_center()
    iso_start = viewport.map_to_iso(view_center.x, view_center.y)
    iso_max_i = viewport.map_to_iso(view_center.x + viewport.canvas_width, view_center.y + viewport.canvas_height)
    iso_max_j = viewport.map_to_iso(view_center.x, view_center.y + viewport.canvas_height)
    iso_min_j = viewport.map_to_iso(view_center.x + viewport.canvas_width, view_center.y)

    i_start = iso_start.i - 8
    j_start = iso_start.j
    i_max = iso_max_i.i + 24
    j_max = iso_max_j.j + 30
    j_min = iso_min_j.j - 6

    n_bump = false
    m_bump = false
    n = 0
    n_buffer = 4
    m = 10
    m_buffer = 6

    sprite_counter = {}
    layer.reset_counter(sprite_counter) for layer in [@land_layer, @tree_layer, @underlay_layer, @building_layer, @building_footprint_layer, @overlay_layer]
    x = i_start
    while x < i_max
      j = j_start - n
      while j < (j_start + m)

        if j > 0 && j < map_height && x > 0 && x < map_width
          canvas = viewport.iso_to_canvas(x, j, view_center)

          tile_info = @info_for_tile(x, j)
          building_metadata = if tile_info.building_info? then @building_manager.building_metadata.buildings[tile_info.building_info.key] else null

          land_sprite = if tile_info.has_ground then @land_layer.sprite_for(sprite_counter, x, j, tile_width, tile_height) else null
          tree_sprite = if tile_info.has_tree then @tree_layer.sprite_for(sprite_counter, x, j, tile_width, tile_height) else null
          underlay_sprite = if tile_info.zone_info? then @underlay_layer.sprite_for(tile_info.zone_info.color, sprite_counter, x, j, tile_width, tile_height) else null
          building_sprite = if tile_info.building_info? && tile_info.building_info.x == x && tile_info.building_info.y == j then (if @ui_state.render_buildings then @building_layer else @building_footprint_layer).sprite_for(tile_info.building_info, sprite_counter, x, j, tile_width, tile_height) else null
          overlay_sprite = if tile_info.overlay_info? then @overlay_layer.sprite_for(tile_info.overlay_info.color, sprite_counter, x, j, tile_width, tile_height) else null

          tree_sprite.render(tile_info, sprite_counter, canvas.x, canvas.y, tile_width, tile_height) if tree_sprite?.within_canvas(canvas.x, canvas.y, viewport)
          land_sprite.render(tile_info, sprite_counter, canvas.x, canvas.y, tile_width, tile_height) if land_sprite?.within_canvas(canvas.x, canvas.y, viewport)
          underlay_sprite.render(tile_info, sprite_counter, canvas.x, canvas.y, tile_width, tile_height) if underlay_sprite?.within_canvas(canvas.x, canvas.y, viewport)
          building_sprite.render(tile_info, sprite_counter, canvas.x, canvas.y, tile_width, tile_height) if building_sprite?.within_canvas(canvas.x, canvas.y, viewport)
          overlay_sprite.render(tile_info, sprite_counter, canvas.x, canvas.y, tile_width, tile_height) if overlay_sprite?.within_canvas(canvas.x, canvas.y, viewport)

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

    layer.hide_sprites(sprite_counter) for layer in [@land_layer, @tree_layer, @underlay_layer, @building_layer, @building_footprint_layer, @overlay_layer]
    @plane_layer.refresh_sprites()

  check_planes: () ->
    return unless @plane_manager.has_assets() && @game_state.initialized && @ui_state.render_planes
    return if @game_state.plane_sprite?

    flight_plan = @plane_manager.random_flight_plan(@renderer.viewport())
    @game_state.plane_sprite = @plane_layer.add_sprite(flight_plan.plane_info, flight_plan.direction, flight_plan.velocity,
        flight_plan.source_map_x, flight_plan.source_map_y, flight_plan.target_map_x, flight_plan.target_map_y)
