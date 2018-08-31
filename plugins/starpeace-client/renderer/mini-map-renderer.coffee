###
global addResizeListener
global PIXI
###

export default class MiniMapRenderer
  constructor: (event_listener, @managers, @game_state, @ui_state) ->
    @initialized = false

    event_listener.subscribe_map_data_listener (chunk_event) =>
      setTimeout((=> @refresh_map()), 1000)

  refresh_map: () ->


  handle_resize: () ->
    render_container = document?.getElementById('mini-map-webgl-container')
    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)
    @application.renderer.resize(@renderer_width, @renderer_height)

  initialize_application: () ->
    return unless document?

    render_container = document.getElementById('mini-map-webgl-container')
    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)

    @application = new PIXI.Application(@renderer_width, @renderer_height, { backgroundColor : 0x00ffff })
    @application.stage = new PIXI.display.Stage()

    render_container.appendChild(@application.view)
    addResizeListener(render_container, => @handle_resize())

  initialize: () ->
    @initialize_application() unless @application?

    @initialized = true


  zoom_in: () ->

  zoom_out: () ->


  tick: () ->
