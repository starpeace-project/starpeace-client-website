

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.Renderer = class Renderer

  constructor: (@client) ->
    @initialized = false

    $render_container = $('#render-container')
    @offset = if $render_container.is(":visible") then $render_container.offset() else null
    @renderer_width = Math.ceil($render_container.outerWidth())
    @renderer_height = Math.ceil($render_container.outerHeight())

    @client.game_state.initialized = false
    @application = new PIXI.Application(@renderer_width, @renderer_height, {
      backgroundColor : 0x000000
    })
    $render_container.append(@application.view)
    new ResizeSensor($render_container, => @handle_resize())

    @input_handler = new starpeace.renderer.InputHandler(@client, @)

  handle_resize: () ->
    $render_container = $('#render-container')
    @offset = if $render_container.is(":visible") then $render_container.offset() else null
    @renderer_width = Math.ceil($render_container.outerWidth())
    @renderer_height = Math.ceil($render_container.outerHeight())
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
    unless @offset?
      $render_container = $('#render-container')
      @offset = $render_container.offset() if $render_container.is(":visible")
    @map_land_layer.refresh() if @map_land_layer?.needs_refresh

