###
global addResizeListener
global PIXI
###

import MetadataLand from '~/plugins/starpeace-client/land/metadata-land.coffee'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import BuildingZone from '~/plugins/starpeace-client/overlay/building-zone.coffee'

import MiniMapInputHandler from '~/plugins/starpeace-client/renderer/input/mini-map-input-handler.coffee'

MINI_MAP_TEXTURE_KEY = 'rendered-mini-map'

MINI_MAP_TILE_WIDTH = Math.sqrt(2)
MINI_MAP_TILE_HEIGHT = MINI_MAP_TILE_WIDTH * .5

export default class MiniMapRenderer
  constructor: (@managers, @renderer, @client_state, @options) ->
    @rgba_buffer = null

    @dragging = false
    @map_offset_x = 0
    @map_offset_y = 0

    @client_state.planet.subscribe_map_data_listener (chunk_event) =>
      source_x = (chunk_event.info.chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 10
      target_x = (chunk_event.info.chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 10
      source_y = (chunk_event.info.chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 10
      target_y = (chunk_event.info.chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 10

      @update_map_data(source_x, target_x, source_y, target_y)

      unless @pending_refresh?
        @pending_refresh = setTimeout((=> @refresh_map_texture()), 500)

    @client_state.camera.subscribe_viewport_listener (event) => @upate_viewport()
    @client_state.interface.subscribe_mini_map_zoom_listener => @update_mini_map_scale()

  update_map_data: (source_x, target_x, source_y, target_y) ->
    return unless @client_state.planet.game_map?.raw_map_rgba_pixels?

    @rgba_buffer = new Uint8ClampedArray(@client_state.planet.game_map.width * @client_state.planet.game_map.height * 4) unless @rgba_buffer?
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = (y * @client_state.planet.game_map.width + x) * 4
        source_index = ((@client_state.planet.game_map.height - x) * @client_state.planet.game_map.width + (@client_state.planet.game_map.width - y)) * 4

        @rgba_buffer[index + 3] = 255

        building_chunk_info = @client_state.planet.game_map.building_map.chunk_building_info_at(x, y)
        road_chunk_info = @client_state.planet.game_map.building_map.chunk_road_info_at(x, y)

        if building_chunk_info?.is_current() && road_chunk_info?.is_current()
          building_info = @client_state.planet.game_map.building_map.building_info_at(x, y)
          building_metadata = if building_info? then @client_state.core.building_library.metadata_by_id[building_info.key] else null
          if @client_state.planet.game_map.road_map.road_info_at(x, y)
            @rgba_buffer[index + 0] = 30
            @rgba_buffer[index + 1] = 30
            @rgba_buffer[index + 2] = 30
          else if building_info? && building_metadata?
            zone = BuildingZone.TYPES[building_metadata.zone] || BuildingZone.TYPES.RESERVED
            color = if zone == BuildingZone.TYPES.CIVICS then 0x1E1E1E else zone.color
            @rgba_buffer[index + 0] = (color & 0xFF0000) >> 16
            @rgba_buffer[index + 1] = (color & 0x00FF00) >> 8
            @rgba_buffer[index + 2] = (color & 0x0000FF) >> 0
          else
            @rgba_buffer[index + 0] = @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 0]
            @rgba_buffer[index + 1] = @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 1]
            @rgba_buffer[index + 2] = @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 2]
        else
          @rgba_buffer[index + 0] = @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 0] - @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 0] * .5
          @rgba_buffer[index + 1] = @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 1] - @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 1] * .5
          @rgba_buffer[index + 2] = @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 2] - @client_state.planet.game_map.raw_map_rgba_pixels[source_index + 2] * .5

  refresh_map_texture: () ->
    return unless @client_state.initialized && @client_state.workflow_status == 'ready'
    image_data = new ImageData(@rgba_buffer, @client_state.planet.game_map.width, @client_state.planet.game_map.height)

    dom_buffer = document.createElement('canvas')
    dom_buffer.width = image_data.width
    dom_buffer.height = image_data.height

    buffer_context = dom_buffer.getContext('2d')
    buffer_context.putImageData(image_data, 0, 0)
    PIXI.utils.TextureCache[MINI_MAP_TEXTURE_KEY] = PIXI.Texture.fromCanvas(dom_buffer)
    @sprite.texture = PIXI.utils.TextureCache[MINI_MAP_TEXTURE_KEY] if @sprite

    @pending_refresh = null

  handle_resize: () ->
    render_container = document?.getElementById('mini-map-webgl-container')
    return unless render_container?

    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)
    @application.renderer.resize(@renderer_width, @renderer_height)

  initialize_application: () ->
    return unless document?
    render_container = document.getElementById('mini-map-webgl-container')
    return unless render_container?

    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)

    @application = new PIXI.Application(@renderer_width, @renderer_height, { backgroundColor : 0x000000 })
    @application.stage = new PIXI.display.Stage()

    @container = new PIXI.Container()
    @container.scale = new PIXI.Point(1, .5)
    @application.stage.addChild(@container)

    @viewport = new PIXI.Graphics()
    @application.stage.addChild(@viewport)

    @input_handler = new MiniMapInputHandler(@, @options)

    render_container.appendChild(@application.view)
    addResizeListener(render_container, => @handle_resize())

  initialize_mini_map_sprite: () ->
    return unless @container?

    mini_map_zoom = @options.option('mini_map.zoom')
    @sprite = new PIXI.Sprite(PIXI.utils.TextureCache[MINI_MAP_TEXTURE_KEY])
    @sprite.interactive = true
    @sprite.scale = new PIXI.Point(mini_map_zoom, mini_map_zoom)
    @sprite.x = @map_offset_x
    @sprite.y = @map_offset_y
    @sprite.rotation = Math.PI * .25
    @container.addChild(@sprite)

  initialize: () ->
    @initialize_application() unless @application?

    render_container = document.getElementById('mini-map-webgl-container')
    render_container.style.visibility = "hidden"

    @update_map_data(0, @client_state.planet.game_map.width, 0, @client_state.planet.game_map.height)
    clearTimeout(@pending_refresh) if @pending_refresh?
    @pending_refresh = setTimeout(=>
      @refresh_map_texture()
      render_container.style.visibility = "visible"
    , 500)

    @last_mini_map_zoom = 0
    @last_game_scale = 0
    @last_view_offset_x = 0
    @last_view_offset_y = 0

    @client_state.mini_map_renderer_initialized = true

  recenter_at: (mini_canvas_x, mini_canvas_y) ->
    mini_map_zoom = @options.option('mini_map.zoom')

    mini_canvas_x = mini_canvas_x - @map_offset_x
    mini_canvas_y = mini_canvas_y - @map_offset_y * .5

    ratio_x = mini_map_zoom * MINI_MAP_TILE_WIDTH / MetadataLand.DEFAULT_TILE_WIDTH
    ratio_y = mini_map_zoom * MINI_MAP_TILE_HEIGHT / MetadataLand.DEFAULT_TILE_HEIGHT

    half_viewport_width = Math.round(ratio_x * @client_state.camera.canvas_width / (2 * @client_state.camera.game_scale))
    half_viewport_height = Math.round(ratio_y * @client_state.camera.canvas_height / (2 * @client_state.camera.game_scale))

    mini_canvas_x = mini_canvas_x - half_viewport_width
    mini_canvas_y = mini_canvas_y - half_viewport_height

    x_ratio = mini_canvas_x / (mini_map_zoom * MINI_MAP_TILE_WIDTH * .5)
    y_ratio = mini_canvas_y / (mini_map_zoom * MINI_MAP_TILE_HEIGHT * .5)
    iso_x = (y_ratio + x_ratio) * 0.5
    iso_y = (y_ratio - x_ratio) * 0.5

    @client_state.camera.top_left_at(iso_x, iso_y)

  offset: (delta_x, delta_y) ->
    @map_offset_x -= delta_x unless delta_x == 0
    @map_offset_y -= (2 * delta_y) unless delta_y == 0

    @upate_viewport()

  update_mini_map_scale: () ->
    mini_map_zoom = @options.option('mini_map.zoom')
    @sprite.scale = new PIXI.Point(mini_map_zoom, mini_map_zoom) if @sprite?

  upate_viewport: () ->
    return unless @client_state.mini_map_renderer_initialized && @sprite?

    mini_map_zoom = @options.option('mini_map.zoom')

    ratio_x = mini_map_zoom * MINI_MAP_TILE_WIDTH / MetadataLand.DEFAULT_TILE_WIDTH
    ratio_y = mini_map_zoom * MINI_MAP_TILE_HEIGHT / MetadataLand.DEFAULT_TILE_HEIGHT

    viewport_width = Math.round(ratio_x * @client_state.camera.canvas_width  / @client_state.camera.game_scale)
    viewport_height = Math.round(ratio_y * @client_state.camera.canvas_height / @client_state.camera.game_scale)

    mini_map_x = Math.round(@client_state.camera.view_offset_x * ratio_x - viewport_width * .5 + @map_offset_x)
    mini_map_y = Math.round(@client_state.camera.view_offset_y * ratio_y - viewport_height * .5 + .5 * @map_offset_y)

    if @last_view_offset_x != @client_state.camera.view_offset_x || @last_view_offset_y != @client_state.camera.view_offset_y
      center_offset_x = mini_map_x - (@renderer_width * .5 - viewport_width * .5)
      center_offset_y = mini_map_y - (@renderer_height * .5 - viewport_height * .5)

      @map_offset_x = Math.round(@map_offset_x - center_offset_x)
      @map_offset_y = Math.round(@map_offset_y - 2 * center_offset_y)

      mini_map_x = Math.round(mini_map_x - center_offset_x)
      mini_map_y = Math.round(@client_state.camera.view_offset_y * ratio_y - viewport_height * .5 + .5 * @map_offset_y)

    @sprite?.x = @map_offset_x
    @sprite?.y = @map_offset_y

    @viewport.clear()
    @viewport.lineStyle(2, 0xFFD0FF, .7)
    @viewport.drawRect(mini_map_x, mini_map_y, viewport_width, viewport_height)

    @last_mini_map_zoom = mini_map_zoom
    @last_game_scale = @client_state.camera.game_scale
    @last_view_offset_x = @client_state.camera.view_offset_x
    @last_view_offset_y = @client_state.camera.view_offset_y

  needs_update: () ->
    @last_mini_map_zoom != @options.option('mini_map.zoom') || @last_game_scale != @client_state.camera.game_scale ||
        @last_view_offset_x != @client_state.camera.view_offset_x || @last_view_offset_y != @client_state.camera.view_offset_y

  tick: () ->
    return unless @client_state.mini_map_renderer_initialized
    @initialize_mini_map_sprite() unless @sprite? || !PIXI.utils.TextureCache[MINI_MAP_TEXTURE_KEY]?
    @upate_viewport() if @needs_update()
