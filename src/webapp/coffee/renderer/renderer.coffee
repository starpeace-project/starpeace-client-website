

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.Renderer = class Renderer

  constructor: (@client) ->
    @client.game_state.initialized = false
    $render_container = $('#render-container')
    @application = new PIXI.Application($render_container.outerWidth(), $render_container.outerHeight(), {
      backgroundColor : 0x00ffff
    })
    $render_container.append(@application.view)

    new ResizeSensor($render_container, => @handle_resize())

  pixels_for_texture: (texture) ->
    render_texture = PIXI.RenderTexture.create(texture.width, texture.height)
    @application.renderer.render(new PIXI.Sprite(texture), render_texture)
    @application.renderer.extract.pixels(render_texture)


  initialize: () ->
    land_metadata_by_color = @client.land_metadata_for_planet_by_color()
    map_texture = @client.asset_manager.map_id_texture[@client.planet.map_id]

    @client.game_state.game_map = starpeace.map.GameMap.from_texture(land_metadata_by_color, map_texture)

    console.log @client.game_state.game_map

    @client.game_state.loading = true
    setTimeout (=> @client.game_state.loading = false), 500

    container = new PIXI.Container()
    @application.stage.addChild(container)
    @client.game_state.initialized = true

  handle_resize: () ->
    $render_container = $('#render-container')
    @application.renderer.resize($render_container.outerWidth(), $render_container.outerHeight())

