
###
global addResizeListener
global FPSMeter
global PIXI
###

import GameMap from '~/plugins/starpeace-client/map/game-map.coffee'
import MapLayers from '~/plugins/starpeace-client/renderer/map/map-layers.coffee'

class Renderer
  constructor: (@client) ->
    @initialized = false
    @client.game_state.initialized = false

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
    @application.renderer.resize(@renderer_width, @renderer_height)
    @initialize_map()

  initialize_application: () ->
    render_container = document?.getElementById('render-container')
    @update_offset(render_container)
    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)
    @application = new PIXI.Application(@renderer_width, @renderer_height, {
      backgroundColor : 0x000000
    })
    render_container.appendChild(@application.view)

    fps_el = document?.getElementById('fps-container')
    @fps_meter = new FPSMeter(fps_el, { theme: 'colorful' }) if fps_el?

    addResizeListener(render_container, => @handle_resize())


  initialize_map: () ->
    @map_layers.remove_layers(@application.stage) if @map_layers?
    @map_layers = new MapLayers(@, @client.game_state, @client.ui_state)
    @map_layers.add_layers(@application.stage)

  initialize: () ->
    @initialize_application() unless @application?

    planet = @client.game_state.current_planet
    land_manifest = @client.planet_type_manifest_manager.planet_type_manifest[planet.planet_type]
    map_texture = @client.asset_manager.map_id_texture[planet.map_id]

    @client.game_state.game_map = GameMap.from_texture(@client, land_manifest, map_texture)
    @initialize_map()

    @client.game_state.loading = true
    setTimeout (=> @client.game_state.loading = false), 500

    @client.game_state.initialized = true
    @initialized = true

  tick: () ->
    @fps_meter.tickStart() if @fps_meter?

    @update_offset(document?.getElementById('render-container')) unless @offset?
    @map_layers.refresh() if @map_layers?.should_refresh()

    @fps_meter.tick() if @fps_meter?

export default Renderer
