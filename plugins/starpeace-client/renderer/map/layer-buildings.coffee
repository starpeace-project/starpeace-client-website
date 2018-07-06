
import Logger from '~/plugins/starpeace-client/logger.coffee'
import LayerBuilding from '~/plugins/starpeace-client/renderer/map/layer-building.coffee'


MAX_GROUND_TILES = 10000

class LayerBuildings
  constructor: (@client, @renderer, @game_state) ->
    @atlas_layer = {}
    @initialized = false
    @initialize()

  @safe_alias: (path) ->
    if path.startsWith('./') then path.substring(2) else path

  containers: () ->
    _.map(_.values(@atlas_layer), (layer) -> layer.container)

  initialize: () ->
    atlases = Object.keys(@client.building_manager.loaded_atlases)
    return unless atlases.length

    @atlas_layer[LayerBuildings.safe_alias(atlas)] = new LayerBuilding(@client, @renderer, @game_state) for atlas in atlases
    @initialized = true

  destroy: () ->
    layer.destroy() for atlas,layer of @atlas_layer
    @initialized = false

  reset_counter: (counter) ->
    counter.building = {}
    counter.building[atlas] = {static:0, animated:0} for atlas,layer of @atlas_layer

  increment_counter: (counter, tile_info) ->
    textures = @client.building_manager.building_textures[tile_info.building_info.key]
    return unless @initialized && textures?.length
    atlas = @client.building_manager.atlas_for(tile_info.building_info.key)
    if textures.length == 1
      counter.building[atlas].static += 1
    else
      counter.building[atlas].animated += 1

  sprite_for: (building_info, counter, x, y) ->
    return null unless @initialized
    atlas = @client.building_manager.atlas_for(building_info.key)
    @atlas_layer[atlas].sprite_for(building_info, counter.building[atlas], x, y)

  hide_sprites: (counter) ->
    layer.hide_sprites(counter.building[atlas]) for atlas,layer of @atlas_layer


export default LayerBuildings
