
import _ from 'lodash'

import TileItem from '~/plugins/starpeace-client/renderer/item/tile-item.coffee'

import SpriteBuilding from '~/plugins/starpeace-client/renderer/sprite/sprite-building.coffee'
import SpriteBuildingFootprint from '~/plugins/starpeace-client/renderer/sprite/sprite-building-footprint.coffee'
import SpriteConcrete from '~/plugins/starpeace-client/renderer/sprite/sprite-concrete.coffee'
import SpriteEffect from '~/plugins/starpeace-client/renderer/sprite/sprite-effect.coffee'
import SpriteLand from '~/plugins/starpeace-client/renderer/sprite/sprite-land.coffee'
import SpriteOverlay from '~/plugins/starpeace-client/renderer/sprite/sprite-overlay.coffee'
import SpritePlane from '~/plugins/starpeace-client/renderer/sprite/sprite-plane.coffee'
import SpriteRoad from '~/plugins/starpeace-client/renderer/sprite/sprite-road.coffee'
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
    @is_dirty = true

    @last_scale_rendered = 0
    @last_season_rendered = null
    @last_rendered_zones = false
    @last_rendered_overlay = false
    @last_rendered_overlay_type = null

    @last_rendered_selection_options = { building_id: null, tycoon_id: null }
    @last_rendered_render_options = { }

    @tile_items = []

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
      for y in [source_y..target_y]
        for x in [source_x..target_x]
          index = y * @client_state.planet.game_map.width + x
          @tile_items[index] = undefined if @tile_items[index]?
    else
      @tile_items = []

    @is_dirty = true

  cache_item: (x, y) ->
    return @tile_items[y * @client_state.planet.game_map.width + x] if @tile_items[y * @client_state.planet.game_map.width + x]?
    tile_info = @client_state.planet.game_map.info_for_tile(x, y)
    is_building_root_tile = tile_info.building_info? && tile_info.building_info.x == x && tile_info.building_info.y == y
    @tile_items[y * @client_state.planet.game_map.width + x] = new TileItem(tile_info, x, y, {
        land: @land_sprite_info_for(tile_info)
        concrete: @concrete_sprite_info_for(tile_info)
        road: @road_sprite_info_for(tile_info)
        tree: @tree_sprite_info_for(tile_info)
        underlay: @underlay_sprite_info_for(tile_info)
        foundation: if !@options.option('renderer.buildings') && is_building_root_tile then @foundation_sprite_info_for(tile_info) else null
        building: if @options.option('renderer.buildings') && is_building_root_tile then @building_sprite_info_for(tile_info) else null
        overlay: @overlay_sprite_info_for(tile_info)
      })

  land_sprite_info_for: (tile_info, viewport) ->
    return null unless tile_info.land_info?

    texture_id = _.values(tile_info.land_info?.textures?['0deg']?[@client_state.planet.current_season] || {})[0]
    texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length

    unless texture?
      Logger.debug("unable to find ground texture <#{texture_id}>, falling back to default")
      texture_id = "#{@client_state.planet.current_season}.255.border.center.1"
      texture = PIXI.utils.TextureCache[texture_id]

    new SpriteLand(texture, tile_info.is_chunk_data_loaded)

  concrete_sprite_info_for: (tile_info, viewport) ->
    return null unless tile_info.concrete_info?
    texture_id = tile_info.concrete_info.type?.texture_id
    return null unless texture_id?.length

    texture = PIXI.utils.TextureCache[texture_id]
    Logger.debug "no concrete texture for #{texture_id}" unless texture?
    return null unless texture?

    new SpriteConcrete(texture, tile_info.concrete_info.type.is_flat == true, tile_info.concrete_info.type.is_platform)

  road_sprite_info_for: (tile_info, viewport) ->
    return null unless tile_info.road_info?
    texture_id = if tile_info.road_info.is_city then tile_info.road_info.type.city_texture_id else tile_info.road_info.type.country_texture_id
    return null unless texture_id?.length

    texture = PIXI.utils.TextureCache[texture_id]
    Logger.debug "no road texture for #{tile_info.road_info.type?.type || 'unknown'}" unless texture?
    return null unless texture?

    new SpriteRoad(texture, tile_info.road_info.type.is_bridge || false, tile_info.road_info.is_over_water)

  tree_sprite_info_for: (tile_info) ->
    return null unless tile_info.tree_info?
    texture_id = tile_info.tree_info?.textures?[@client_state.planet.current_season]
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
    return null unless tile_info.building_info?
    metadata = @client_state.core.building_library.metadata_by_id[tile_info.building_info.key]
    return null unless metadata?
    image_metadata = @client_state.core.building_library.images_by_id[metadata.image_id]
    return null unless image_metadata?

    texture = PIXI.utils.TextureCache["overlay.#{image_metadata.w}"]
    return null unless texture?

    zone_color = BuildingZone.TYPES[metadata.zone]?.color

    new SpriteBuildingFootprint(texture, image_metadata, zone_color)

  building_sprite_info_for: (tile_info) ->
    return null unless tile_info.building_info?
    metadata = @client_state.core.building_library.metadata_by_id[tile_info.building_info.key]
    return null unless metadata?
    image_metadata = @client_state.core.building_library.images_by_id[metadata.image_id]
    return null unless image_metadata?

    textures = _.map(image_metadata?.frames || [], (texture_id) -> PIXI.utils.TextureCache[texture_id])
    return null unless textures?.length && textures[0]?

    is_animated = textures.length > 1 && @options.option('renderer.building_animations')

    effects = []
    if image_metadata.effects? && @options.option('renderer.building_effects')
      for effect in image_metadata.effects
        effect_metadata = @client_state.core.effect_library.metadata_by_id[effect.type]
        effect_textures = _.map(effect_metadata?.frames || [], (texture_id) -> PIXI.utils.TextureCache[texture_id])
        continue unless effect_metadata? && effect_textures.length
        effects.push(new SpriteEffect(effect_textures, effect, effect_metadata))

    is_selected = false
    is_filtered = false
    if @client_state.interface.selected_building_id?.length
      is_selected = @client_state.interface.selected_building_id == tile_info.building_info.id
      selected_corporation_id = @client_state.selected_building_metadata()?.corporation_id
      is_filtered = if selected_corporation_id?.length then selected_corporation_id != tile_info.building_info.corporation_id else true

    new SpriteBuilding(textures, is_animated, is_selected, is_filtered, image_metadata, effects)

  plane_sprite_info_for: (flight_plan) ->
    textures = @client_state.core.plane_library.texture_for_id(flight_plan.plane_info.id)
    return null unless textures?.length
    new SpritePlane(textures, flight_plan)
