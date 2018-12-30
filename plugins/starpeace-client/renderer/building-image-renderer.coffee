###
global addResizeListener
global PIXI
###

WEBGL_CONTAINER = 'construction-image-webgl-container'

export default class BuildingImageRenderer
  constructor: (@managers, @client_state, @options) ->

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
    render_container = document?.getElementById(WEBGL_CONTAINER)
    return unless render_container?

    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)
    @application.renderer.resize(@renderer_width, @renderer_height)

    @update_building_sprite()

  initialize_application: () ->
    render_container = document?.getElementById(WEBGL_CONTAINER)
    return unless render_container?

    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)

    # backgroundColor : 0x000000
    @application = new PIXI.Application(@renderer_width, @renderer_height, { transparent: true })
    @application.stage = new PIXI.display.Stage()

    @container = new PIXI.Container()
    @application.stage.addChild(@container)

    render_container.appendChild(@application.view)
    addResizeListener(render_container, => @handle_resize())

  initialize: () ->
    @initialize_application() unless @application?

    @last_building_id = null

    @client_state.construction_preview_renderer_initialized = true

  update_building_sprite: () ->
    return unless @client_state.mini_map_renderer_initialized

    unless @sprite?
      @sprite = new PIXI.Sprite(PIXI.Texture.EMPTY)
      @container.addChild(@sprite)

    if @client_state.interface.construction_selected_building_id?.length
      building_metadata = @client_state.core.building_library.metadata_by_id[@client_state.interface.construction_selected_building_id]
      building_image = if building_metadata?.image_id? then @client_state.core.building_library.images_by_id[building_metadata.image_id] else null
      texture = if building_image?.frames?.length then PIXI.utils.TextureCache[building_image.frames[0]] else PIXI.Texture.EMPTY

      height_if_render_width = @renderer_width * (texture.height / texture.width)
      width_if_render_height = @renderer_height * (texture.width / texture.height)

      [texture_width, texture_height] = if height_if_render_width > @renderer_height then [width_if_render_height, @renderer_height] else [@renderer_width, height_if_render_width]

      @sprite.texture = texture
      @sprite.x = (@renderer_width - texture_width) / 2
      @sprite.y = (@renderer_height - texture_height) / 2
      @sprite.scale = new PIXI.Point(texture_width / texture.width, texture_height / texture.height)

    @last_building_id = @client_state.interface.construction_selected_building_id

  needs_update: () -> @last_building_id != @client_state.interface.construction_selected_building_id

  tick: () ->
    return unless @client_state.construction_preview_renderer_initialized && @client_state?.menu?.is_visible('construction') && @client_state.interface.construction_selected_building_id?.length
    @update_building_sprite() if @needs_update()
