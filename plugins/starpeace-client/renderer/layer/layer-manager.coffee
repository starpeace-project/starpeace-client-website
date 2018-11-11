
###
global PIXI
###

import LayerCache from '~/plugins/starpeace-client/renderer/layer/layer-cache.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class LayerManager
  @MAX_PARTICLES: 65536

  constructor: (@game_state, @ui_state) ->
    @land_container = new PIXI.particles.ParticleContainer(LayerManager.MAX_PARTICLES, { tint: true, uvs: true, vertices: true })
    @land_container.zIndex = 0
    @land_sprite_cache = new LayerCache(@land_container, null, LayerManager.MAX_PARTICLES, false, false)

    @concrete_container = new PIXI.particles.ParticleContainer(LayerManager.MAX_PARTICLES, { uvs: true, vertices: true })
    @concrete_container.zIndex = 0
    @concrete_sprite_cache = new LayerCache(@concrete_container, null, LayerManager.MAX_PARTICLES, false, false)

    @underlay_container = new PIXI.particles.ParticleContainer(LayerManager.MAX_PARTICLES, { tint: true, vertices: true })
    @underlay_container.zIndex = 1
    @underlay_sprite_cache = new LayerCache(@underlay_container, null, LayerManager.MAX_PARTICLES, false, false)

    @road_container = new PIXI.particles.ParticleContainer(LayerManager.MAX_PARTICLES, { uvs: true, vertices: true })
    @road_container.zIndex = 2
    @road_sprite_cache = new LayerCache(@road_container, null, LayerManager.MAX_PARTICLES, false, false)

    @foundation_container = new PIXI.particles.ParticleContainer(LayerManager.MAX_PARTICLES, { tint: true, uvs: true, vertices: true })
    @foundation_container.zIndex = 2
    @foundation_sprite_cache = new LayerCache(@foundation_container, null, LayerManager.MAX_PARTICLES, false, false)

    @with_height_container = new PIXI.Container()
    @with_height_container.zIndex = 3
    @with_height_zorder_layer = new PIXI.display.Layer(new PIXI.display.Group(3, true))
    @with_height_static_sprite_cache = new LayerCache(@with_height_container, @with_height_zorder_layer, 0, false, true)
    @with_height_animated_sprite_cache = new LayerCache(@with_height_container, @with_height_zorder_layer, 0, true, true)

    @overlay_container = new PIXI.particles.ParticleContainer(LayerManager.MAX_PARTICLES, { tint: true, vertices: true })
    @overlay_container.zIndex = 4
    @overlay_sprite_cache = new LayerCache(@overlay_container, null, LayerManager.MAX_PARTICLES, false, false)

    @plane_container = new PIXI.Container()
    @plane_container.zIndex = 5
    @plane_sprite_cache = new LayerCache(@plane_container, null, 0, true, false)

    @containers = [@land_container, @concrete_container, @underlay_container, @road_container, @foundation_container, @with_height_container, @overlay_container, @plane_container]
    @sprite_caches = [@land_sprite_cache, @concrete_sprite_cache, @underlay_sprite_cache, @road_sprite_cache, @foundation_sprite_cache, @with_height_static_sprite_cache, @with_height_animated_sprite_cache, @overlay_sprite_cache]
    Logger.debug "configured #{@containers.length} layers and #{@sprite_caches.length} caches for sprite rendering"

  destroy: () ->
    container.destroy({ children: true, textures: false }) for container in @containers

  remove_from_stage: (stage) ->
    stage.removeChild(@with_height_zorder_layer)
    stage.removeChild(container) for container in @containers

  add_to_stage: (stage) ->
    stage.addChild(@with_height_zorder_layer)
    stage.addChild(container) for container in @containers

  clear_cache_sprites: (render_state) ->
    cache.clear_cache(render_state) for cache in @sprite_caches

  plane_sprite_with: (textures) ->
    @plane_sprite_cache.new_sprite({}, { textures })

  render_tile_item: (render_state, tile_item, canvas, viewport) ->
    if tile_item.sprite_info.land?.within_canvas(canvas, viewport)
      land = @land_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.land.texture })
      tile_item.sprite_info.land.render(land, canvas, viewport)

    has_concrete_with_height = if tile_item.sprite_info.concrete? then !tile_item.sprite_info.concrete.is_flat || tile_item.sprite_info.concrete.is_platform else false
    if tile_item.sprite_info.concrete?.within_canvas(canvas, viewport)
      sprite_cache = if has_concrete_with_height then @with_height_static_sprite_cache else @concrete_sprite_cache
      concrete = sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.concrete.texture })
      concrete_underlay = @with_height_static_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.underlay.texture }) if has_concrete_with_height && tile_item.sprite_info.underlay?
      tile_item.sprite_info.concrete.render(concrete, canvas, viewport)
      tile_item.sprite_info.underlay.render(concrete_underlay, concrete.zOrder, false, canvas, viewport) if concrete_underlay?

    has_road_with_height = if tile_item.sprite_info.road? then has_concrete_with_height || tile_item.sprite_info.road.is_bridge || tile_item.sprite_info.road.is_over_water else false
    if tile_item.sprite_info.road?.within_canvas(canvas, viewport)
      sprite_cache = if has_road_with_height then @with_height_static_sprite_cache else @road_sprite_cache
      road = sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.road.texture })
      road_underlay = @with_height_static_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.underlay.texture }) if has_road_with_height && tile_item.sprite_info.underlay?
      tile_item.sprite_info.road.render(road, canvas, viewport)
      tile_item.sprite_info.underlay.render(road_underlay, road.zOrder, false, canvas, viewport) if road_underlay?

    if !(has_road_with_height || has_concrete_with_height) && !tile_item.sprite_info.tree? && tile_item.sprite_info.underlay?.within_canvas(canvas, viewport)
      underlay = @underlay_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.underlay.texture })
      tile_item.sprite_info.underlay.render(underlay, null, false, canvas, viewport)

    if tile_item.sprite_info.tree?.within_canvas(canvas, viewport)
      tree = @with_height_static_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.tree.texture })
      tree_underlay = @with_height_static_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.underlay.texture }) if tile_item.sprite_info.underlay?
      tile_item.sprite_info.tree.render(tree, canvas, viewport)
      tile_item.sprite_info.underlay.render(tree_underlay, tree.zOrder, true, canvas, viewport) if tree_underlay?

    if tile_item.sprite_info.foundation?.within_canvas(canvas, viewport)
      foundation = @foundation_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.foundation.texture })
      tile_item.sprite_info.foundation.render(foundation, canvas, viewport)

    if tile_item.sprite_info.building?.within_canvas(canvas, viewport)
      select_building_callback = () =>
        if tile_item.tile_info.building_info.id == @game_state.selected_building_id
          @game_state.selected_building_id = null
          @game_state.selected_corporation_id = null
        else
          @game_state.selected_building_id = tile_item.tile_info.building_info.id
          @game_state.selected_corporation_id = tile_item.tile_info.building_info.corporation_id
          console.log tile_item.tile_info.building_info

      sprite_cache = if tile_item.sprite_info.building.is_animated then @with_height_animated_sprite_cache else @with_height_static_sprite_cache
      building = sprite_cache.new_sprite(render_state, { textures:tile_item.sprite_info.building.textures, speed:.15, hit_area:tile_item.sprite_info.building.hit_area(viewport), click_callback:select_building_callback })
      tile_item.sprite_info.building.render(building, canvas, viewport)

      for effect_info in tile_item.sprite_info.building.effects
        effect = @with_height_animated_sprite_cache.new_sprite(render_state, { textures:effect_info.textures, speed:.1 })
        effect_info.render(effect, building, canvas, viewport)

    if tile_item.sprite_info.overlay?.within_canvas(canvas, viewport)
      overlay = @overlay_sprite_cache.new_sprite(render_state, { texture:tile_item.sprite_info.overlay.texture })
      tile_item.sprite_info.overlay.render(overlay, null, false, canvas, viewport)
