
import MetadataOverlay from '~/plugins/starpeace-client/overlay/metadata-overlay.coffee'
import Overlay from '~/plugins/starpeace-client/overlay/overlay.coffee'
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map'

import Logger from '~/plugins/starpeace-client/logger'

export default class OverlayManager
  constructor: (@api, @asset_manager, @ajax_state, @client_state) ->

  queue_asset_load: () ->
    return if @client_state.core.overlay_library.has_assets() || @ajax_state.is_locked('assets.overlay_metadata', 'ALL')

    @ajax_state.lock('assets.overlay_metadata', 'ALL')
    @asset_manager.queue('metadata.overlay', './overlay.metadata.json', (resource) =>
      overlay_metadata = []
      for key,json of (resource.overlays || {})
        # FIXME: TODO: add ID to json, change from map to array
        json.id = key
        overlay_metadata.push MetadataOverlay.from_json(json)

      @client_state.core.overlay_library.load_overlay_metadata(overlay_metadata)
      @client_state.core.overlay_library.load_required_atlases(resource.atlas)

      @asset_manager.queue_and_load_atlases((resource.atlas || []), (atlas_path, atlas) =>
        # mip-mapping has bigger impact without edge aliasing
        # TODO: why isn't this, or PIXI.settings.MIPMAP_TEXTURES, working?
        atlas.spritesheet.baseTexture.mipmap = false if atlas.spritesheet?.baseTexture?.mipmap?

        @client_state.core.overlay_library.load_atlas(atlas_path, atlas)
      )
      @ajax_state.unlock('assets.overlay_metadata', 'ALL')
    )

  load_chunk: (type, chunk_x, chunk_y) ->
    throw Error() if !@client_state.has_session() || !type? || !chunk_x? || !chunk_y?

    return new Array(ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT) if type == 'NONE'
    if type == 'TOWNS'
      @deserialize_towns_chunk(chunk_x, chunk_y)
    else
      await @ajax_state.locked('planet_overlays', "#{type}x#{chunk_x}x#{chunk_y}", =>
        overlay_data = await @api.overlay_data_for_planet(type, chunk_x, chunk_y)
        return new Array(ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT) unless overlay_data?

        if type == 'ZONES'
          @deserialize_zone_chunk(ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT, overlay_data)
        else
          @deserialize_overlay_chunk(type, ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT, overlay_data)
      )

  deserialize_towns_chunk: (chunk_x, chunk_y) ->
    data = new Array(ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT)
    pixels = @client_state.planet.game_map.towns_rgba_pixels
    x_offset = ChunkMap.CHUNK_WIDTH * chunk_x
    y_offset = ChunkMap.CHUNK_HEIGHT * chunk_y
    for y in [0...ChunkMap.CHUNK_HEIGHT]
      for x in [0...ChunkMap.CHUNK_WIDTH]
        color = @client_state.planet.game_map.town_color_at(x + x_offset, y + y_offset)
        data[y * ChunkMap.CHUNK_WIDTH + x] = {
          value: color
          color: color
        }
    data

  deserialize_zone_chunk: (width, height, data) ->
    zones = new Array(width * height)
    unless data.length == zones.length
      Logger.warn("unable to deserialize city zone chunk (needed #{zones.length}, had #{data.length})")
      return zones

    for y in [0...height]
      for x in [0...width]
        type_value = data[y * width + x]
        continue unless type_value > 0
        city_zone = @client_state.core.planet_library.zone_for_value(type_value)
        if city_zone?
          zones[y * width + x] = city_zone
        else
          Logger.warn("unable to find city zone for value #{type_value}")
    zones

  deserialize_overlay_chunk: (type, width, height, data) ->
    overlay = Overlay.TYPES[type]
    throw "unknown overlay type #{type}" unless overlay?

    overlay_data = new Array(width * height)
    unless data.length == overlay_data.length
      Logger.warn("unable to deserialize overlay chunk (needed #{overlay_data.length}, had #{data.length})")
      return zones

    for y in [0...height]
      for x in [0...width]
        overlay_value = data[y * width + x]
        overlay_data[y * width + x] = {
          value: overlay_value
          color: parseInt(overlay.color_gradient.rgbAt(overlay_value / 255).toHex(), 16)
        }
    overlay_data
