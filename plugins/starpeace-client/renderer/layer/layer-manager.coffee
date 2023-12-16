
import * as PIXI from 'pixi.js'

import LayerCache from '~/plugins/starpeace-client/renderer/layer/layer-cache.coffee'

import Logger from '~/plugins/starpeace-client/logger'

export default class LayerManager
  @MAX_PARTICLES: 65536

  constructor: (@client_state) ->
    @land_container = new PIXI.ParticleContainer(LayerManager.MAX_PARTICLES, { tint: true, uvs: true, vertices: true })
    @land_container.eventMode = 'none'
    @land_container.zIndex = 0
    @land_sprite_cache = new LayerCache(@land_container, null, LayerManager.MAX_PARTICLES, false, false)

    @concrete_container = new PIXI.ParticleContainer(LayerManager.MAX_PARTICLES, { uvs: true, vertices: true })
    @concrete_container.eventMode = 'none'
    @concrete_container.zIndex = 0
    @concrete_sprite_cache = new LayerCache(@concrete_container, null, LayerManager.MAX_PARTICLES, false, false)

    @underlay_container = new PIXI.ParticleContainer(LayerManager.MAX_PARTICLES, { tint: true, vertices: true })
    @underlay_container.eventMode = 'none'
    @underlay_container.zIndex = 1
    @underlay_sprite_cache = new LayerCache(@underlay_container, null, LayerManager.MAX_PARTICLES, false, false)

    @road_container = new PIXI.ParticleContainer(LayerManager.MAX_PARTICLES, { uvs: true, vertices: true })
    @road_container.eventMode = 'none'
    @road_container.zIndex = 2
    @road_sprite_cache = new LayerCache(@road_container, null, LayerManager.MAX_PARTICLES, false, false)

    @foundation_container = new PIXI.ParticleContainer(LayerManager.MAX_PARTICLES, { tint: true, uvs: true, vertices: true })
    @land_container.eventMode = 'none'
    @foundation_container.zIndex = 2
    @foundation_sprite_cache = new LayerCache(@foundation_container, null, LayerManager.MAX_PARTICLES, false, false)

    @with_height_container = new PIXI.Container()
    @with_height_container.zIndex = 3
    @with_height_container.sortableChildren = true
    @with_height_static_sprite_cache = new LayerCache(@with_height_container, null, 0, false, true)
    @with_height_animated_sprite_cache = new LayerCache(@with_height_container, null, 0, true, true)

    @overlay_container = new PIXI.ParticleContainer(LayerManager.MAX_PARTICLES, { tint: true, vertices: true })
    @overlay_container.eventMode = 'none'
    @overlay_container.zIndex = 4
    @overlay_sprite_cache = new LayerCache(@overlay_container, null, LayerManager.MAX_PARTICLES, false, false)

    @plane_container = new PIXI.Container()
    @plane_container.eventMode = 'none'
    @plane_container.zIndex = 5
    @plane_sprite_cache = new LayerCache(@plane_container, null, 0, true, false)

    @building_graphics_background = new PIXI.Graphics()
    @building_graphics_background.visible = false
    @building_graphics_foreground = new PIXI.Graphics()
    @building_graphics_foreground.visible = false
    @with_height_container.addChild(@building_graphics_background)
    @with_height_container.addChild(@building_graphics_foreground)

    @building_text_style = new PIXI.TextStyle({
        align: 'center',
        fontFamily: 'Open Sans',
        fontSize: 24,
        fontWeight: 'bold',
        fill: ['#ffff00'],
        stroke: '#000000',
        strokeThickness: 4,
        dropShadow: true,
        dropShadowColor: '#000000',
        dropShadowDistance: 2
    })
    @building_text = new PIXI.Text('', @building_text_style)
    @building_text.anchor.set(0.5, 1)
    @building_text.visible = false
    @with_height_container.addChild(@building_text)


    @containers = [@land_container, @concrete_container, @underlay_container, @road_container, @foundation_container, @with_height_container, @overlay_container, @plane_container]
    @sprite_caches = [@land_sprite_cache, @concrete_sprite_cache, @underlay_sprite_cache, @road_sprite_cache, @foundation_sprite_cache, @with_height_static_sprite_cache, @with_height_animated_sprite_cache, @overlay_sprite_cache]
    Logger.debug "configured #{@containers.length} layers and #{@sprite_caches.length} caches for sprite rendering"

  destroy: () ->
    container.destroy({ children: true, textures: false }) for container in @containers

  remove_from_stage: (stage) ->
    stage.removeChild(container) for container in @containers

  add_to_stage: (stage) ->
    stage.addChild(container) for container in @containers

  clear_cache_sprites: (render_state) ->
    cache.clear_cache(render_state) for cache in @sprite_caches

  clear_cache_plane_sprites: (render_state) ->
    @plane_sprite_cache.clear_cache(render_state)

  plane_sprite_with: (render_state, textures) ->
    @plane_sprite_cache.new_sprite(render_state, { textures })


  render_building_selection: (viewport, building_sprite, building_image_metadata, building_label) ->
    @building_graphics_background.clear()
    @building_graphics_foreground.clear()

    @building_text.text = building_label
    @building_text.scale.set(viewport.game_scale * 0.5)

    offset_y = viewport.tile_height * 0.75

    @building_graphics_background.x = building_sprite.x
    @building_graphics_background.y = building_sprite.y - offset_y
    @building_graphics_background.zIndex = building_sprite.zIndex - 1
    @building_graphics_foreground.x = building_sprite.x
    @building_graphics_foreground.y = building_sprite.y - offset_y
    @building_graphics_foreground.zIndex = building_sprite.zIndex + 1

    middle_x = building_sprite.width * 0.5

    @building_text.x = building_sprite.x + middle_x
    @building_text.y = building_sprite.y
    @building_text.zIndex = building_sprite.zIndex + 2

    h_a = building_image_metadata.h * viewport.tile_height * 0.5

    hx = building_sprite.width * 0.15 # === 0.5 * 0.3
    hy = hx * 0.5 # === sin(30deg)
    vy = (building_sprite.height - 2 * h_a + offset_y) * 0.3

    @building_graphics_background.lineStyle({width: 2, native: false, color: 0x00FF00})
    @building_graphics_foreground.lineStyle({width: 2, native: false, color: 0x00FF00})

    # top west
    @building_graphics_background.moveTo(0, h_a).lineTo(hx, h_a + hy)
    @building_graphics_foreground.moveTo(0, h_a).lineTo(hx, h_a - hy)
    @building_graphics_foreground.moveTo(0, h_a).lineTo(0, h_a + vy)

    # top north
    @building_graphics_background.moveTo(middle_x, 0).lineTo(middle_x, vy)
    @building_graphics_background.moveTo(middle_x, 0).lineTo(middle_x - hx, hy)
    @building_graphics_background.moveTo(middle_x, 0).lineTo(middle_x + hx, hy)

    # top south
    # in front of building, omit to avoid obscuring

    # top east
    @building_graphics_background.moveTo(building_sprite.width, h_a).lineTo(building_sprite.width - hx, h_a + hy)
    @building_graphics_foreground.moveTo(building_sprite.width, h_a).lineTo(building_sprite.width - hx, h_a - hy)
    @building_graphics_foreground.moveTo(building_sprite.width, h_a).lineTo(building_sprite.width, h_a + vy)

    # bottom west
    bottom_west_y = offset_y + building_sprite.height - h_a - 1
    @building_graphics_background.moveTo(0, bottom_west_y).lineTo(hx, bottom_west_y - hy)
    @building_graphics_foreground.moveTo(0, bottom_west_y).lineTo(hx, bottom_west_y + hy)
    @building_graphics_foreground.moveTo(0, bottom_west_y).lineTo(0, bottom_west_y - vy)

    # bottom north
    # usually behind building, omit for performance

    # bottom south
    bottom_south_y = building_sprite.height + offset_y - 1
    @building_graphics_foreground.moveTo(middle_x, bottom_south_y).lineTo(middle_x, bottom_south_y - vy)
    @building_graphics_foreground.moveTo(middle_x, bottom_south_y).lineTo(middle_x - hx, bottom_south_y - hy)
    @building_graphics_foreground.moveTo(middle_x, bottom_south_y).lineTo(middle_x + hx, bottom_south_y - hy)

    # bottom east
    bottom_east_y = offset_y + building_sprite.height - h_a
    @building_graphics_background.moveTo(building_sprite.width, bottom_east_y - 1).lineTo(building_sprite.width - hx, bottom_east_y - hy - 1)
    @building_graphics_foreground.moveTo(building_sprite.width, bottom_east_y - 1).lineTo(building_sprite.width - hx, bottom_east_y + hy - 1)
    @building_graphics_foreground.moveTo(building_sprite.width, bottom_east_y - 1).lineTo(building_sprite.width, bottom_east_y - vy - 1)

    @building_graphics_background.visible = true
    @building_graphics_foreground.visible = true
    @building_text.visible = true


  render_tile_item: (render_state, tile_item, selected_building_label, construction_item, within_construction, canvas, viewport) ->
    if (within_construction || !within_construction && !tile_item.sprite_info.tree?) && tile_item.sprite_info.land?.within_canvas(canvas, viewport)
      land = @land_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.land.texture })
      tile_item.sprite_info.land.render(land, canvas, viewport)

    has_concrete_with_height = if tile_item.sprite_info.concrete? then !tile_item.sprite_info.concrete.is_flat || tile_item.sprite_info.concrete.is_platform else false
    if tile_item.sprite_info.concrete?.within_canvas(canvas, viewport)
      sprite_cache = if has_concrete_with_height then @with_height_static_sprite_cache else @concrete_sprite_cache
      concrete = sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.concrete.texture })
      concrete_underlay = @with_height_static_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.underlay.texture }) if has_concrete_with_height && tile_item.sprite_info.underlay?
      tile_item.sprite_info.concrete.render(concrete, canvas, viewport)
      tile_item.sprite_info.underlay.render(concrete_underlay, concrete.zIndex, false, canvas, viewport) if concrete_underlay?

    has_road_with_height = if tile_item.sprite_info.road? then has_concrete_with_height || tile_item.sprite_info.road.is_bridge || tile_item.sprite_info.road.is_over_water else false
    if tile_item.sprite_info.road?.within_canvas(canvas, viewport)
      sprite_cache = if has_road_with_height then @with_height_static_sprite_cache else @road_sprite_cache
      road = sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.road.texture })
      road_underlay = @with_height_static_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.underlay.texture }) if has_road_with_height && tile_item.sprite_info.underlay?
      tile_item.sprite_info.road.render(road, canvas, viewport)
      tile_item.sprite_info.underlay.render(road_underlay, road.zIndex, false, canvas, viewport) if road_underlay?

    if !(has_road_with_height || has_concrete_with_height) && !tile_item.sprite_info.tree? && tile_item.sprite_info.underlay?.within_canvas(canvas, viewport)
      underlay = @underlay_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.underlay.texture })
      tile_item.sprite_info.underlay.render(underlay, null, false, canvas, viewport)

    if !within_construction && tile_item.sprite_info.tree?.within_canvas(canvas, viewport)
      tree = @with_height_static_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.tree.texture })
      tree_underlay = @with_height_static_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.underlay.texture }) if tile_item.sprite_info.underlay?
      tile_item.sprite_info.tree.render(tree, canvas, viewport)
      tile_item.sprite_info.underlay.render(tree_underlay, tree.zIndex, true, canvas, viewport) if tree_underlay?

    if tile_item.sprite_info.foundation?.within_canvas(canvas, viewport)
      foundation = @foundation_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.foundation.texture })
      tile_item.sprite_info.foundation.render(foundation, canvas, viewport)

    if tile_item.sprite_info.building?.within_canvas(canvas, viewport)
      select_building_callback = (left_click, right_click) =>
        return false if @client_state.interface.construction_building_id?.length
        if left_click
          @client_state.interface.toggle_building(tile_item.tile_info.building_info.id)
        else if right_click
          @client_state.interface.select_and_inspect_building(tile_item.tile_info.building_info.id)
        @client_state.interface.is_mouse_primary_down = false if @client_state.interface.is_mouse_primary_down
        true

      sprite_cache = if tile_item.sprite_info.building.is_animated then @with_height_animated_sprite_cache else @with_height_static_sprite_cache
      building = sprite_cache.new_sprite(render_state, { textures:tile_item.sprite_info.building.textures, speed:.15, hit_area:tile_item.sprite_info.building.hit_area(viewport), click_callback:select_building_callback })
      tile_item.sprite_info.building.render(building, canvas, viewport)

      for effect_info in tile_item.sprite_info.building.effects
        effect = @with_height_animated_sprite_cache.new_sprite(render_state, { textures:effect_info.textures, speed:.1 })
        effect_info.render(effect, building, canvas, viewport)

      for sign_info in tile_item.sprite_info.building.signs
        sign = @with_height_animated_sprite_cache.new_sprite(render_state, { textures:sign_info.textures, speed:.1 })
        sign_info.render(sign, building, canvas, viewport)

      if tile_item.sprite_info.building.is_selected
        @render_building_selection(viewport, building, tile_item.sprite_info.building.image_metadata, selected_building_label)


    if construction_item?.within_canvas(canvas, viewport)
      sprite_cache = if construction_item.is_animated then @with_height_animated_sprite_cache else @with_height_static_sprite_cache
      building_construction = sprite_cache.new_sprite(render_state, { textures:construction_item.textures, speed:.15, hit_area:construction_item.hit_area(viewport) })
      construction_item.render(building_construction, canvas, viewport)


    if tile_item.sprite_info.overlay?.within_canvas(canvas, viewport)
      overlay = @overlay_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.overlay.texture })
      tile_item.sprite_info.overlay.render(overlay, null, false, canvas, viewport)
