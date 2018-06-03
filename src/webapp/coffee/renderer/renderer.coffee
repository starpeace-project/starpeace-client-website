

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.Renderer = class Renderer

  constructor: (@client) ->
    @initialized = false

    $render_container = $('#render-container')
    @renderer_width = $render_container.outerWidth()
    @renderer_height = $render_container.outerHeight()

    @client.game_state.initialized = false
    @application = new PIXI.Application(@renderer_width, @renderer_height, {
      backgroundColor : 0x00ffff
    })
    $render_container.append(@application.view)

    new ResizeSensor($render_container, => @handle_resize())

    @is_moving = false
    @last_x = -1
    @last_y = -1
    @application.renderer.plugins.interaction.on('pointerdown', (event) =>
      @is_moving = true
      event = event?.data?.originalEvent
      return unless event?

      @last_x = Math.round(event.x)
      @last_y = Math.round(event.y)
    )
    @application.renderer.plugins.interaction.on('pointermove', (event) =>
      return unless @is_moving
      event = event?.data?.originalEvent
      return unless event?

      event_x = Math.round(event.x)
      event_y = Math.round(event.y)

      delta_x = if @last_x >= 0 then @last_x - event_x else 0
      delta_y = if @last_y >= 0 then @last_y - event_y else 0

      @client.game_state.view_offset_x += delta_x unless delta_x == 0
      @client.game_state.view_offset_y += delta_y unless delta_y == 0

      @last_x = event_x
      @last_y = event_y

      @map_land_layer.needs_refresh = true if @map_land_layer?
    )

    finish_moving = (event) =>
      @is_moving = false
      event = event?.data?.originalEvent
      return unless event?

      @last_x = Math.round(event.x)
      @last_y = Math.round(event.y)

    @application.renderer.plugins.interaction.on('pointerup', finish_moving)
    @application.renderer.plugins.interaction.on('pointercancel', finish_moving)
    @application.renderer.plugins.interaction.on('pointerout', finish_moving)


  handle_resize: () ->
    $render_container = $('#render-container')
    @renderer_width = $render_container.outerWidth()
    @renderer_height = $render_container.outerHeight()
    @application.renderer.resize(@renderer_width, @renderer_height)
    @initialize_map()


#   pixels_for_texture: (texture) ->
#     render_texture = PIXI.RenderTexture.create(texture.width, texture.height)
#     @application.renderer.render(new PIXI.Sprite(texture), render_texture)
#     @application.renderer.extract.pixels(render_texture)

  initialize_map: (land_manifest) ->
    @application.stage.removeChild(@map_land_layer.container) if @map_land_layer
    @map_land_layer = new starpeace.renderer.MapLandLayer(@, land_manifest, @client.game_state)
    @application.stage.addChild(@map_land_layer.container)

  initialize: () ->
    land_manifest = @client.land_manifest_for_planet()
    map_texture = @client.asset_manager.map_id_texture[@client.planet.map_id]

    @client.game_state.game_map = starpeace.map.GameMap.from_texture(land_manifest, map_texture)
    @initialize_map(land_manifest)

    @client.game_state.loading = true
    setTimeout (=> @client.game_state.loading = false), 500

    container = new PIXI.Container()
    @application.stage.addChild(container)

    @client.game_state.initialized = true
    @initialized = true

  tick: () ->
    @map_land_layer.refresh() if @map_land_layer?.needs_refresh

