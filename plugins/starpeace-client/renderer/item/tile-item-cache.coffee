
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
  constructor: (@building_manager, @effect_manager, @plane_manager, @game_state, @options, @ui_state) ->
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
    return true if @game_state.game_scale != @last_scale_rendered || @game_state.current_season != @last_season_rendered ||
      @ui_state.show_zones != @last_rendered_zones || @ui_state.show_overlay != @last_rendered_overlay || @ui_state.current_overlay.type != @last_rendered_overlay_type ||
      @game_state.selected_building_id != @last_rendered_selection_options.building_id || @game_state.selected_corporation_id != @last_rendered_selection_options.corporation_id

    for option in RENDER_OPTIONS
      return true unless @options.option(option) == @last_rendered_render_options[option]

    false

  reset_cache: () ->
    @last_scale_rendered = @game_state.game_scale
    @last_season_rendered = @game_state.current_season
    @last_rendered_zones = @ui_state.show_zones
    @last_rendered_overlay = @ui_state.show_overlay
    @last_rendered_overlay_type = @ui_state.current_overlay.type

    @last_rendered_selection_options.building_id = @game_state.selected_building_id
    @last_rendered_selection_options.corporation_id = @game_state.selected_corporation_id

    @last_rendered_render_options[option] = @options.option(option) for option in RENDER_OPTIONS

    @is_dirty = false

  clear_cache: (source_x, target_x, source_y, target_y) ->
    if source_x? && target_x? && source_y? && target_y?
      for y in [source_y..target_y]
        for x in [source_x..target_x]
          index = y * @game_state.game_map.width + x
          @tile_items[index] = undefined if @tile_items[index]?
    else
      @tile_items = []

    @is_dirty = true

  cache_item: (x, y) ->
    return @tile_items[y * @game_state.game_map.width + x] if @tile_items[y * @game_state.game_map.width + x]?
    tile_info = @game_state.game_map.info_for_tile(x, y)
    is_building_root_tile = tile_info.building_info? && tile_info.building_info.x == x && tile_info.building_info.y == y
    @tile_items[y * @game_state.game_map.width + x] = new TileItem(tile_info, x, y, {
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

    texture_id = _.values(tile_info.land_info?.textures?['0deg']?[@game_state.current_season] || {})[0]
    texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length

    unless texture?
      Logger.debug("unable to find ground texture <#{texture_id}>, falling back to default")
      texture_id = "#{@game_state.current_season}.255.border.center.1"
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
    texture_id = tile_info.tree_info?.textures?[@game_state.current_season]
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
    metadata = @building_manager.building_metadata.buildings[tile_info.building_info.key]
    return null unless metadata?
    texture = PIXI.utils.TextureCache["overlay.#{metadata.w}"]
    return null unless texture?

    new SpriteBuildingFootprint(texture, metadata)

  building_sprite_info_for: (tile_info) ->
    return null unless tile_info.building_info?
    textures = @building_manager.building_textures[tile_info.building_info.key]
    return null unless textures?.length && textures[0]?

    is_animated = textures.length > 1 && @options.option('renderer.building_animations')
    metadata = @building_manager.building_metadata.buildings[tile_info.building_info.key]

    effects = []
    if metadata.effects? && @options.option('renderer.building_effects')
      for effect in metadata.effects
        effect_metadata = @effect_manager.effect_metadata.effects[effect.type]
        effect_textures = @effect_manager.effect_textures[effect.type]
        continue unless effect_metadata? && effect_textures?.length
        effects.push(new SpriteEffect(effect_textures, effect, effect_metadata))

    is_selected = if @game_state.selected_building_id?.length then @game_state.selected_building_id == tile_info.building_info.id else false
    is_filtered = if @game_state.selected_corporation_id?.length then @game_state.selected_corporation_id != tile_info.building_info.corporation_id else false

    new SpriteBuilding(textures, is_animated, is_selected, is_filtered, metadata, effects)

  plane_sprite_info_for: (flight_plan) ->
    textures = @plane_manager.plane_textures[flight_plan.plane_info.key]
    return null unless textures?.length
    new SpritePlane(textures, flight_plan)
