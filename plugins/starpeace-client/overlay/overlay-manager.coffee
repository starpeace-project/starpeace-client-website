
import Logger from '~/plugins/starpeace-client/logger.coffee'

import BuildingZone from '~/plugins/starpeace-client/overlay/building-zone.coffee'
import MetadataOverlay from '~/plugins/starpeace-client/overlay/metadata-overlay.coffee'
import Overlay from '~/plugins/starpeace-client/overlay/overlay.coffee'

DUMMY_ZONE_CHUNK_DATA = {}
for type in ['ZONES', 'BEAUTY', 'HC_RESIDENTIAL', 'MC_RESIDENTIAL', 'LC_RESIDENTIAL', 'QOL',
    'CRIME', 'POLLUTION', 'BAP', 'FRESH_FOOD', 'PROCESSED_FOOD', 'CLOTHES', 'APPLIANCES',
    'CARS', 'RESTAURANTS', 'BARS', 'TOYS', 'DRUGS', 'MOVIES', 'GASOLINE', 'COMPUTERS',
    'FURNITURE', 'BOOKS', 'COMPACT_DISCS', 'FUNERAL_PARLORS']
  for chunk_y in [2...9]
    for chunk_x in [8...14]
      info = DUMMY_ZONE_CHUNK_DATA["#{type}x#{chunk_x}x#{chunk_y}"] = {
        chunk_x: chunk_x
        chunk_y: chunk_y
        width: 20
        height: 20
        data: []
      }

      if type == 'ZONES'
        info.data = "1111122222333334444411111222223333344444111112222233333444441111122222333334444411111222223333344444" +
            "5555566666777778888855555666667777788888555556666677777888885555566666777778888855555666667777111888" +
            "9999900000000012100099999000000000111000999990000000000000009999900000000000000099999000000000000000" +
            "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      else
        magnitude = 0.5 + 0.5 * Math.random()
        for y in [0...20]
          for x in [0...20]
            distance = Math.sqrt((10 - x) * (10 - x) + (10 - y) * (10 - y))
            info.data[y * 20 + x] = Math.round(255 * (1 - Math.min(1, magnitude * (distance / 10)))).toString(16).padStart(2, '0')
        info.data = info.data.join('')

export default class OverlayManager
  constructor: (@asset_manager, @ajax_state, @client_state) ->
    @chunk_promises = {}

  load_chunk: (type, chunk_x, chunk_y, width, height) ->
    key = "#{type}x#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    Logger.debug("attempting to load overlay chunk for #{type} at #{chunk_x}x#{chunk_y}")
    @ajax_state.start_ajax()
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
        @ajax_state.finish_ajax()
      , 500)

  queue_asset_load: () ->
    return if @client_state.core.overlay_library.has_assets() || @ajax_state.is_locked('assets.overlay_metadata', 'ALL')

    @ajax_state.lock('assets.overlay_metadata', 'ALL')
    @asset_manager.queue('metadata.overlay', './overlay.metadata.json', (resource) =>
      overlay_metadata = []
      for key,json of (resource.data?.overlays || {})
        # FIXME: TODO: add ID to json, change from map to array
        json.id = key
        overlay_metadata.push MetadataOverlay.from_json(json)

      @client_state.core.overlay_library.load_overlay_metadata(overlay_metadata)
      @client_state.core.overlay_library.load_required_atlases(resource.data?.atlas)

      @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) =>
        # mip-mapping has bigger impact without edge aliasing
        # TODO: why isn't this, or PIXI.settings.MIPMAP_TEXTURES, working?
        atlas.spritesheet.baseTexture.mipmap = false if atlas.spritesheet?.baseTexture?.mipmap?

        @client_state.core.overlay_library.load_atlas(atlas_path, atlas)
      )
      @ajax_state.unlock('assets.overlay_metadata', 'ALL')
    )
