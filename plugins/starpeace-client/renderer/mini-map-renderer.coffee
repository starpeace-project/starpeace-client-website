###
global addResizeListener
global PIXI
###

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import BuildingZone from '~/plugins/starpeace-client/map/types/building-zone.coffee'

MINI_MAP_TEXTURE_KEY = 'rendered-mini-map'

export default class MiniMapRenderer
  constructor: (event_listener, @managers, @game_state, @ui_state) ->
    @initialized = false
    @rgba_buffer = null

    @dragging = false
    @map_offset_x = 0
    @map_offset_y = 0

    event_listener.subscribe_map_data_listener (chunk_event) =>
      source_x = (chunk_event.info.chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 10
      target_x = (chunk_event.info.chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 10
      source_y = (chunk_event.info.chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 10
      target_y = (chunk_event.info.chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 10

      @update_map_data(source_x, target_x, source_y, target_y)

      unless @pending_refresh?
        @pending_refresh = setTimeout((=> @refresh_map_texture()), 500)

  update_map_data: (source_x, target_x, source_y, target_y) ->
    return unless @game_state.game_map?.raw_map_rgba_pixels?

    @rgba_buffer = new Uint8ClampedArray(@game_state.game_map.width * @game_state.game_map.height * 4) unless @rgba_buffer?
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = (y * @game_state.game_map.width + x) * 4
        source_index = ((@game_state.game_map.height - x) * @game_state.game_map.width + (@game_state.game_map.width - y)) * 4

        @rgba_buffer[index + 3] = 255

        building_chunk_info = @game_state.game_map.building_map.chunk_building_info_at(x, y)
        road_chunk_info = @game_state.game_map.building_map.chunk_road_info_at(x, y)

        if building_chunk_info?.is_current() && road_chunk_info?.is_current()
          building_info = @game_state.game_map.building_map.building_info_at(x, y)
          building_metadata = if building_info? then @managers.building_manager.building_metadata.buildings[building_info.key] else null
          if @game_state.game_map.road_map.road_info_at(x, y)
            @rgba_buffer[index + 0] = 255
            @rgba_buffer[index + 1] = 255
            @rgba_buffer[index + 2] = 255
          else if building_info? && building_metadata?
            color = BuildingZone.TYPES[building_metadata.zone]?.color || BuildingZone.TYPES.RESERVED.color
            @rgba_buffer[index + 0] = (color & 0xFF0000) >> 16
            @rgba_buffer[index + 1] = (color & 0x00FF00) >> 8
            @rgba_buffer[index + 2] = (color & 0x0000FF) >> 0
          else
            @rgba_buffer[index + 0] = @game_state.game_map.raw_map_rgba_pixels[source_index + 0]
            @rgba_buffer[index + 1] = @game_state.game_map.raw_map_rgba_pixels[source_index + 1]
            @rgba_buffer[index + 2] = @game_state.game_map.raw_map_rgba_pixels[source_index + 2]
        else
          @rgba_buffer[index + 0] = @game_state.game_map.raw_map_rgba_pixels[source_index + 0] - @game_state.game_map.raw_map_rgba_pixels[source_index + 0] * .5
          @rgba_buffer[index + 1] = @game_state.game_map.raw_map_rgba_pixels[source_index + 1] - @game_state.game_map.raw_map_rgba_pixels[source_index + 1] * .5
          @rgba_buffer[index + 2] = @game_state.game_map.raw_map_rgba_pixels[source_index + 2] - @game_state.game_map.raw_map_rgba_pixels[source_index + 2] * .5

  refresh_map_texture: () ->
    image_data = new ImageData(@rgba_buffer, @game_state.game_map.width, @game_state.game_map.height)

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

    render_container.appendChild(@application.view)
    addResizeListener(render_container, => @handle_resize())

  initialize: () ->
    @initialize_application() unless @application?

    @update_map_data(0, @game_state.game_map.width, 0, @game_state.game_map.height)
    @pending_refresh = setTimeout((=> @refresh_map_texture()), 1000)

    @initialized = true

  map_drag_start: (event) ->
    event = event?.data
    return unless event? && event.isPrimary
    @start_x = @last_x = Math.round(event.global.x)
    @start_y = @last_y = Math.round(event.global.y)
    @dragging = true
  map_drag_end: (event) ->
    event = event?.data
    return unless @dragging && event? && event.isPrimary
    @last_x = Math.round(event.global.x)
    @last_y = Math.round(event.global.y)
    @dragging = false
  map_drag_move: (event) ->
    event = event?.data
    return unless @dragging && event? && event.isPrimary

    event_x = Math.round(event.global.x)
    event_y = Math.round(event.global.y)

    delta_x = if @last_x >= 0 then @last_x - event_x else 0
    delta_y = if @last_y >= 0 then @last_y - event_y else 0
    @last_x = event_x
    @last_y = event_y

    @map_offset_x -= delta_x unless delta_x == 0
    @map_offset_y -= delta_y unless delta_y == 0

    # console.log "#{@map_offset_x} x #{@map_offset_y}"
    @sprite.x = @map_offset_x
    @sprite.y = @map_offset_y

  zoom_in: () ->
    return if @ui_state.mini_map_zoom + .5 > 6
    @ui_state.update_mini_map_zoom(.5)
    @sprite.scale = new PIXI.Point(@ui_state.mini_map_zoom, @ui_state.mini_map_zoom) if @sprite?

  zoom_out: () ->
    return if @ui_state.mini_map_zoom - .5 < .5
    @ui_state.update_mini_map_zoom(-.5)
    @sprite.scale = new PIXI.Point(@ui_state.mini_map_zoom, @ui_state.mini_map_zoom) if @sprite?

  tick: () ->
    unless @sprite? || !PIXI.utils.TextureCache[MINI_MAP_TEXTURE_KEY]?
      @sprite = new PIXI.Sprite(PIXI.utils.TextureCache[MINI_MAP_TEXTURE_KEY])
      # @sprite.anchor.set(0.5)
      @sprite.interactive = true
      @sprite.on('pointerdown', (event) => @map_drag_start(event))
        .on('pointerup', (event) => @map_drag_end(event))
        .on('pointerupoutside', (event) => @map_drag_end(event))
        .on('pointermove', (event) => @map_drag_move(event))
      #@sprite.position = new PIXI.Point(@game_state.game_map.width * .5, @game_state.game_map.height * .5)
      @sprite.scale = new PIXI.Point(@ui_state.mini_map_zoom, @ui_state.mini_map_zoom)
      @sprite.x = @map_offset_x
      @sprite.y = @map_offset_y
      @sprite.rotation = Math.PI * .25
      @container.addChild(@sprite)
