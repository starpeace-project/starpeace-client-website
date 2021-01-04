
import 'javascript-detect-element-resize'
import * as PIXI from 'pixi.js'

export default class BuildingImageRenderer
  constructor: (@managers, @client_state, @webgl_dom_id, @check_initialized_callback, @initialize_callback, @building_id_callback, @options) ->

  handle_resize: () ->
    render_container = document?.getElementById(@webgl_dom_id)
    return unless render_container?

    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)
    @application.renderer.resize(@renderer_width, @renderer_height)

    @update_building_sprite()

  initialize_application: () ->
    render_container = document?.getElementById(@webgl_dom_id)
    return unless render_container?

    @renderer_width = Math.ceil(render_container.offsetWidth)
    @renderer_height = Math.ceil(render_container.offsetHeight)

    @application = new PIXI.Application({
      width: @renderer_width
      height: @renderer_height
      transparent: true
    })

    @container = new PIXI.Container()
    @application.stage.addChild(@container)

    render_container.appendChild(@application.view)
    addResizeListener(render_container, => @handle_resize())

  initialize: () ->
    @initialize_application() unless @application?

    @last_building_id = null
    @initialize_callback()

  update_building_sprite: () ->
    return unless @check_initialized_callback()

    unless @sprite?
      @sprite = new PIXI.Sprite(PIXI.Texture.EMPTY)
      @container.addChild(@sprite)

    building_id = @building_id_callback()
    if building_id?.length
      definition = @client_state.core.building_library.definition_for_id(building_id)
      building_image = if definition?.image_id? then @client_state.core.building_library.images_by_id[definition.image_id] else null
      texture = if building_image?.frames?.length then PIXI.utils.TextureCache[building_image.frames[0]] else PIXI.Texture.EMPTY

      height_if_render_width = @renderer_width * (texture.height / texture.width)
      width_if_render_height = @renderer_height * (texture.width / texture.height)

      [texture_width, texture_height] = if height_if_render_width > @renderer_height then [width_if_render_height, @renderer_height] else [@renderer_width, height_if_render_width]

      @sprite.texture = texture
      @sprite.x = (@renderer_width - texture_width) / 2
      @sprite.y = (@renderer_height - texture_height) / 2
      @sprite.scale = new PIXI.Point(texture_width / texture.width, texture_height / texture.height)

    @last_building_id = building_id

  needs_update: () -> @last_building_id != @building_id_callback()

  tick: () ->
    return unless @check_initialized_callback()
    @update_building_sprite() if @needs_update()
