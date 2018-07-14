
import Logger from '~/plugins/starpeace-client/logger.coffee'

import BuildingZone from '~/plugins/starpeace-client/map/building-zone.coffee'
import Overlay from '~/plugins/starpeace-client/map/overlay.coffee'

DUMMY_ZONE_CHUNK_DATA = {}
for type in ['ZONES', 'BEAUTY', 'HC_RESIDENTIAL', 'MC_RESIDENTIAL', 'LC_RESIDENTIAL', 'QOL',
    'CRIME', 'POLLUTION', 'BAP', 'FRESH_FOOD', 'PROCESSED_FOOD', 'CLOTHES', 'APPLIANCES',
    'CARS', 'RESTAURANTS', 'BARS', 'TOYS', 'DRUGS', 'MOVIES', 'GASOLINE', 'COMPUTERS',
    'FURNITURE', 'BOOKS', 'COMPACT_DISCS', 'FUNERAL_PARLORS']
  for chunk_y in [2...5]
    for chunk_x in [8...11]
      info = DUMMY_ZONE_CHUNK_DATA["#{type}x#{chunk_x}x#{chunk_y}"] = {
        chunk_x: chunk_x
        chunk_y: chunk_y
        width: 20
        height: 20
        data: []
      }

      if type == 'ZONES'
        info.data = "1111122222333334444411111222223333344444111112222233333444441111122222333334444411111222223333344444" +
            "5555566666777778888855555666667777788888555556666677777888885555566666777778888855555666667777788888" +
            "9999900000000000000099999000000000000000999990000000000000009999900000000000000099999000000000000000" +
            "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      else
        magnitude = 0.5 + 0.5 * Math.random()
        for y in [0...20]
          for x in [0...20]
            distance = Math.sqrt((10 - x) * (10 - x) + (10 - y) * (10 - y))
            info.data[y * 20 + x] = Math.round(255 * (1 - Math.min(1, magnitude * (distance / 10)))).toString(16).padStart(2, '0')
        info.data = info.data.join('')

class OverlayManager
  constructor: (@client) ->
    @requested_overlay_metadata = false
    @overlay_metadata = null
    @loaded_atlases = {}
    @chunk_promises = {}

  load_chunk: (type, chunk_x, chunk_y, width, height) ->
    key = "#{type}x#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    Logger.debug("attempting to load overlay chunk for #{type} at #{chunk_x}x#{chunk_y}")
    @client.game_state.start_ajax()
    @chunk_promises[key] = new Promise (done) =>
      data = new Array(width, height).fill(Overlay.TYPES.NONE)

      chunk = DUMMY_ZONE_CHUNK_DATA[key]
      if type == 'ZONES'
        data = BuildingZone.deserialize_chunk(chunk.width, chunk.height, chunk.data) if chunk?
      else if type != 'NONE' && type != 'TOWNS'
        data = Overlay.deserialize_chunk(type, chunk.width, chunk.height, chunk.data) if chunk?

      setTimeout(=>
        delete @chunk_promises[key]
        done(data)
        @client.game_state.finish_ajax()
      , 500)

  has_assets: () ->
    @overlay_metadata? && @overlay_metadata.atlas.length == Object.keys(@loaded_atlases).length

  queue_asset_load: () ->
    return if @requested_overlay_metadata
    @requested_overlay_metadata = true
    @client.asset_manager.queue('metadata.overlay', './overlay.metadata.json', (resource) =>
      @overlay_metadata = resource.data
      overlay.key = key for key,overlay of @overlay_metadata.overlays
      @load_overlay_atlas(resource.data.atlas)
    )

  load_overlay_atlas: (atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @client.asset_manager.queue(path, path, (resource) =>
          @loaded_atlases[path] = resource

          # mip-mapping has bigger impact without edge aliasing
          # TODO: why isn't this, or PIXI.settings.MIPMAP_TEXTURES, working?
          resource.spritesheet.baseTexture.mipmap = false

          @client.notify_assets_changed()
        )
    @client.asset_manager.load_queued()

export default OverlayManager
