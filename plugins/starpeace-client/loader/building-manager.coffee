
import Logger from '~/plugins/starpeace-client/logger.coffee'

MOCK_DATA = {}
MOCK_DATA['9x4'] = [{
  key: 'generic.portal.in'
  x: 190
  y: 90
},
{
  key: 'generic.portal.out'
  x: 192
  y: 90
},
{
  key: 'generic.portal.in'
  x: 194
  y: 90
},
{
  key: 'generic.portal.out'
  x: 196
  y: 90
},
{
  key: 'pgi.townhall'
  x: 198
  y: 90
},
{
  key: 'generic.portal.out'
  x: 190
  y: 92
},
{
  key: 'generic.portal.in'
  x: 192
  y: 92
},
{
  key: 'generic.portal.out'
  x: 194
  y: 92
},
{
  key: 'generic.portal.in'
  x: 190
  y: 94
},
{
  key: 'generic.portal.out'
  x: 192
  y: 94
},
{
  key: 'generic.portal.in'
  x: 194
  y: 94
}]


class BuildingManager
  constructor: (@client) ->
    @chunk_promises = {}

    @requested_building_metadata = false
    @building_metadata = null
    @loaded_atlases = {}
    @building_textures = {}

  load_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    Logger.debug("attempting to load building chunk at #{chunk_x}x#{chunk_y}")
    @client.game_state.start_ajax()
    @chunk_promises[key] = new Promise (done) =>
      setTimeout(=>
        delete @chunk_promises[key]

        data = []
        data = MOCK_DATA[key] if MOCK_DATA[key]?

        done(data)
        @client.game_state.finish_ajax()
      , 500)

  has_assets: () ->
    @building_metadata? && @building_metadata.atlas.length == Object.keys(@loaded_atlases).length

  queue_asset_load: () ->
    return if @requested_building_metadata
    @requested_building_metadata = true
    @client.asset_manager.queue('metadata.building', './building.metadata.json', (resource) =>
      @building_metadata = resource.data
      building.key = key for key,building of @building_metadata.buildings
      @load_building_atlas(resource.data.atlas)
    )

  load_building_atlas: (atlas_paths) ->
    @client.asset_manager.queue(path, path, (resource) =>
      @set_building_atlas(path, resource)
    ) for path in atlas_paths
    @client.asset_manager.load_queued()

  buildings_for_atlas: (atlas_key) ->
    atlas_key = atlas_key.substring(2) if atlas_key.startsWith('./')
    buildings = []
    for key,building of @building_metadata.buildings
      buildings.push(building) if building.atlas == atlas_key
      true
    buildings

  set_building_atlas: (key, atlas) ->
    @loaded_atlases[key] = atlas
    for building in @buildings_for_atlas(key)
      @building_textures[building.key] = _.map(building.frames, (frame) -> PIXI.utils.TextureCache[frame])
    @client.notify_assets_changed()

export default BuildingManager
