import _ from 'lodash'
import * as PIXI from 'pixi.js'

import TileItem from '~/plugins/starpeace-client/renderer/item/tile-item.coffee'

import SpriteBuilding from '~/plugins/starpeace-client/renderer/sprite/sprite-building.coffee'
import SpriteBuildingConstruction from '~/plugins/starpeace-client/renderer/sprite/sprite-building-construction.coffee'
import SpriteBuildingFootprint from '~/plugins/starpeace-client/renderer/sprite/sprite-building-footprint.coffee'
import SpriteConcrete from '~/plugins/starpeace-client/renderer/sprite/sprite-concrete.coffee'
import SpriteEffect from '~/plugins/starpeace-client/renderer/sprite/sprite-effect.coffee'
import SpriteLand from '~/plugins/starpeace-client/renderer/sprite/sprite-land.coffee'
import SpriteOverlay from '~/plugins/starpeace-client/renderer/sprite/sprite-overlay.coffee'
import SpritePlane from '~/plugins/starpeace-client/renderer/sprite/sprite-plane.coffee'
import SpriteRoad from '~/plugins/starpeace-client/renderer/sprite/sprite-road.coffee'
import SpriteSign from '~/plugins/starpeace-client/renderer/sprite/sprite-sign.coffee'
import SpriteTree from '~/plugins/starpeace-client/renderer/sprite/sprite-tree.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

RENDER_OPTIONS = [
  'renderer.trees',
  'renderer.buildings',
  'renderer.building_animations',
  'renderer.building_effects',
  'renderer.planes'
]

export default class TileItemCache
  constructor: (@building_manager, @effect_manager, @plane_manager, @client_state, @options) ->
    @building_library = @client_state.core.building_library
    @effect_library = @client_state.core.effect_library
    @plane_library = @client_state.core.plane_library
    @sign_library = @client_state.core.sign_library

    @is_dirty = true

    @last_scale_rendered = 0
    @last_season_rendered = null
    @last_rendered_zones = false
    @last_rendered_overlay = false
    @last_rendered_overlay_type = null

    @last_rendered_selection_options = { building_id: null }
    @last_rendered_render_options = { }

    @tile_items = {}

  should_clear_cache: () ->
    return true if @client_state.camera.game_scale != @last_scale_rendered || @client_state.planet.current_season != @last_season_rendered ||
      @client_state.interface.show_zones != @last_rendered_zones || @client_state.interface.show_overlay != @last_rendered_overlay || @client_state.interface.current_overlay.type != @last_rendered_overlay_type ||
      @client_state.interface.selected_building_id != @last_rendered_selection_options.building_id

    for option in RENDER_OPTIONS
      return true unless @options.option(option) == @last_rendered_render_options[option]

    false

  reset_cache: () ->
    @last_scale_rendered = @client_state.camera.game_scale
    @last_season_rendered = @client_state.planet.current_season
    @last_rendered_zones = @client_state.interface.show_zones
    @last_rendered_overlay = @client_state.interface.show_overlay
    @last_rendered_overlay_type = @client_state.interface.current_overlay.type

    @last_rendered_selection_options.building_id = @client_state.interface.selected_building_id

    @last_rendered_render_options[option] = @options.option(option) for option in RENDER_OPTIONS

    @is_dirty = false

  clear_cache: (source_x, target_x, source_y, target_y) ->
    if @client_state.planet.game_map? && source_x? && target_x? && source_y? && target_y?
      game_map_width = @client_state.planet.game_map.width
      for y in [source_y..target_y]
        for x in [source_x..target_x]
          index = y * game_map_width + x
          delete @tile_items[index] if @tile_items[index]?
    else
      @tile_items = {}

    @is_dirty = true

  cache_item: (tile_info, tile_cache_index, x, y, current_season, render_buildings, selected_building_id, selected_corporation_id) ->
    is_building_root_tile = tile_info.building_info? && tile_info.building_info.map_x == x && tile_info.building_info.map_y == y
    @tile_items[tile_cache_index] = new TileItem(tile_info, x, y, {
        land: @land_sprite_info_for(tile_info, current_season)
        concrete: @concrete_sprite_info_for(tile_info)
        road: @road_sprite_info_for(tile_info)
        tree: @tree_sprite_info_for(tile_info, current_season)
        underlay: @underlay_sprite_info_for(tile_info)
        foundation: if !render_buildings && is_building_root_tile then @foundation_sprite_info_for(tile_info) else null
        building: if render_buildings && is_building_root_tile then @building_sprite_info_for(tile_info, selected_building_id, selected_corporation_id) else null
        overlay: @overlay_sprite_info_for(tile_info)
      })

  land_sprite_info_for: (tile_info, current_season) ->
    return null unless tile_info.land_info?

    texture_id = _.values(tile_info.land_info?.textures?['0deg']?[current_season] || {})[0]
    texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length

    unless texture?
      Logger.debug("unable to find ground texture <#{texture_id}>, falling back to default")
      texture_id = "#{current_season}.255.border.center.1"
      texture = PIXI.utils.TextureCache[texture_id]

    new SpriteLand(texture, tile_info.is_chunk_data_loaded)

  concrete_sprite_info_for: (tile_info) ->
    return null unless tile_info.concrete_info?
    texture_id = tile_info.concrete_info.type?.texture_id
    return null unless texture_id?.length

    texture = PIXI.utils.TextureCache[texture_id]
    Logger.debug "no concrete texture for #{texture_id}" unless texture?
    return null unless texture?

    new SpriteConcrete(texture, tile_info.concrete_info.type.is_flat == true, tile_info.concrete_info.type.is_platform)

  road_sprite_info_for: (tile_info) ->
    return null unless tile_info.road_info?
    texture_id = if tile_info.road_info.is_city then tile_info.road_info.type.city_texture_id else tile_info.road_info.type.country_texture_id
    return null unless texture_id?.length

    texture = PIXI.utils.TextureCache[texture_id]
    Logger.debug "no road texture for #{tile_info.road_info.type?.type || 'unknown'}" unless texture?
    return null unless texture?

    new SpriteRoad(texture, tile_info.road_info.type.is_bridge || false, tile_info.road_info.is_over_water)

  tree_sprite_info_for: (tile_info, current_season) ->
    return null unless tile_info.tree_info?
    texture_id = tile_info.tree_info?.textures?[current_season]
    return null unless texture_id?.length

    texture = PIXI.utils.TextureCache[texture_id]
    Logger.debug("unable to find tree texture <#{texture_id}>") unless texture?
    return null unless texture?

    new SpriteTree(texture, tile_info.is_chunk_data_loaded)

  underlay_sprite_info_for: (tile_info) ->
    return null unless tile_info.zone_info? && PIXI.utils.TextureCache['overlay.1']?
    new SpriteOverlay(PIXI.utils.TextureCache['overlay.1'], tile_info.zone_info.color)

  overlay_sprite_info_for: (tile_info) ->
    return null unless tile_info.overlay_info? && PIXI.utils.TextureCache['overlay.1']?
    new SpriteOverlay(PIXI.utils.TextureCache['overlay.1'], tile_info.overlay_info.color)

  foundation_sprite_info_for: (tile_info) ->
    unless tile_info.building_info?
      Logger.warn("attempting to determine foundation sprite for unknown building #{tile_info}")
      return null

    metadata = @building_library.metadata_by_id[tile_info.building_info.definition_id]
    unless metadata?
      Logger.warn("unable to load building definition metadata for #{tile_info.building_info.definition_id}")
      return null

    image_metadata = @building_library.images_by_id[metadata.image_id]
    unless image_metadata?
      Logger.warn("unable to load building image metadata for #{metadata.image_id}")
      return null

    texture = PIXI.utils.TextureCache["overlay.#{image_metadata.w}"]
    unless texture?
      Logger.warn("unable to find cached overlay texture for size #{image_metadata.w}")
      return null

    zone_color = if metadata.zone? then metadata.zone.color else 0
    new SpriteBuildingFootprint(texture, image_metadata, zone_color)

  building_sprite_info_for: (tile_info, selected_building_id, selected_corporation_id) ->
    unless tile_info.building_info?
      Logger.warn("attempting to determine building sprite for unknown building #{tile_info}")
      return null

    metadata = @building_library.metadata_by_id[tile_info.building_info.definition_id]
    unless metadata?
      Logger.warn("unable to load building definition metadata for #{tile_info.building_info.definition_id}")
      return null

    image_metadata = if tile_info.building_info.stage >= 0 then @building_library.images_by_id[metadata.image_id] else @building_library.images_by_id[metadata.construction_image_id]
    unless image_metadata?
      Logger.warn("unable to load building image metadata for #{metadata.image_id} stage #{tile_info.building_info.stage}")
      return null

    textures = _.map(image_metadata?.frames || [], (texture_id) -> PIXI.utils.TextureCache[texture_id])
    unless textures?.length && textures[0]?
      Logger.warn("unable to load building textures for #{image_metadata.id}")
      return null

    is_animated = textures.length > 1 && @options.option('renderer.building_animations')

    effects = []
    if image_metadata.effects? && @options.option('renderer.building_effects')
      for effect in image_metadata.effects
        effect_metadata = @effect_library.metadata_by_id[effect.type]
        effect_textures = _.map(effect_metadata?.frames || [], (texture_id) -> PIXI.utils.TextureCache[texture_id])
        continue unless effect_metadata? && effect_textures.length
        effects.push(new SpriteEffect(effect_textures, effect, effect_metadata))

    signs = []
    if metadata.sign_id? && image_metadata.sign?
      sign_metadata = @sign_library.metadata_by_id[metadata.sign_id]
      sign_textures = _.map(sign_metadata?.frames || [], (texture_id) -> PIXI.utils.TextureCache[texture_id])
      signs.push(new SpriteSign(sign_textures, image_metadata.sign, sign_metadata)) if sign_metadata? && sign_textures.length

    is_selected = false
    is_filtered = false
    if selected_building_id?.length
      is_selected = selected_building_id == tile_info.building_info.id
      is_filtered = if selected_corporation_id?.length then selected_corporation_id != tile_info.building_info.corporation_id else true

    new SpriteBuilding(textures, is_animated, is_selected, is_filtered, image_metadata, effects, signs)

  building_construction_sprite_info_for: (building_id, is_valid_location) ->
    metadata = @building_library.metadata_by_id[building_id]
    return null unless metadata?
    image_metadata = @building_library.images_by_id[metadata.image_id]
    return null unless image_metadata?

    textures = _.map(image_metadata?.frames || [], (texture_id) -> PIXI.utils.TextureCache[texture_id])
    return null unless textures?.length && textures[0]?

    is_animated = textures.length > 1 && @options.option('renderer.building_animations')

    new SpriteBuildingConstruction(textures, is_animated, is_valid_location, image_metadata)

  plane_sprite_info_for: (flight_plan) ->
    textures = _.map(flight_plan.plane_info.frames, (frame_id) => @plane_library.texture_for_id(frame_id))
    return null unless textures?.length
    new SpritePlane(textures, flight_plan)
