import '~/plugins/javascript-detect-element-resize/detect-element-resize';
import { Application, Renderer as PixiRenderer } from 'pixi.js';
import Stats from 'stats.js';

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'

import InputHandler from '~/plugins/starpeace-client/renderer/input/input-handler.coffee'
import Layers from '~/plugins/starpeace-client/renderer/layer/layers.coffee'

export default class Renderer
  constructor: (@managers, @client_state, @options) ->
    @client_state.planet.subscribe_map_data_listener (chunk_event) =>
      if @layers?.tile_item_cache?
        source_x = (chunk_event.info.chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 10
        target_x = (chunk_event.info.chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 10
        source_y = (chunk_event.info.chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 10
        target_y = (chunk_event.info.chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 10
        @layers.tile_item_cache.clear_cache(source_x, target_x, source_y, target_y)

  update_offset: (render_container) ->
    if render_container? && render_container.offsetParent != null
      rect = render_container.getBoundingClientRect()
      @offset = {
        top: rect.top + document.body.scrollTop
        left: rect.left + document.body.scrollLeft
      }
    else
      @offset = null

  handle_resize: () ->
    render_container = document?.getElementById('render-container')
    @update_offset(render_container)
    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)
    @client_state.camera.resize(@renderer_width, @renderer_height)
    @application.renderer.resize(@renderer_width, @renderer_height)
    @initialize_map()

  initialize_application: () ->
    return unless document?
    setTimeout(scrollTo, 0, 0, 1)

    render_container = document.getElementById('render-container')
    @update_offset(render_container)
    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)
    @client_state.camera.resize(@renderer_width, @renderer_height)

    @application = new Application({
      width: @renderer_width
      height: @renderer_height
      backgroundColor : 0x000000
    })

    @client_state.webgl_warning = !(@application.renderer instanceof PixiRenderer)

    render_container.appendChild(@application.view)

    @input_handler = new InputHandler(@managers, @, render_container, @client_state)

    fps_el = document?.getElementById('fps-container')
    if fps_el?
      @fps_meter = new Stats()
      fps_el.appendChild(@fps_meter.dom)

    addResizeListener(render_container, => @handle_resize())

  initialize_map: () ->
    @layers?.remove_layers(@application.stage)
    @layers?.destroy()
    @layers = new Layers(@, @managers.building_manager, @managers.effect_manager, @managers.plane_manager, @client_state, @options)
    @layers.add_layers(@application.stage)

  initialize: () ->
    @initialize_application() unless @application?
    @initialize_map()

    @client_state.renderer_initialized = true

  tick: () ->
    return unless @client_state.renderer_initialized

    @fps_meter.begin() if @fps_meter?

    @update_offset(document?.getElementById('render-container')) unless @offset?

    @client_state.planet_event_client.updateViewTarget() if @layers?.has_dirty_view()
    @layers.refresh() if @layers?.should_refresh()
    @layers?.refresh_planes()

    @fps_meter.end() if @fps_meter?
