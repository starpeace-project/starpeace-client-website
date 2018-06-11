

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.Renderer = class Renderer

  constructor: (@client) ->
    @initialized = false
    @client.game_state.initialized = false

  handle_resize: () ->
    $render_container = $('#render-container')
    @offset = if $render_container.is(":visible") then $render_container.offset() else null
    @renderer_width = Math.ceil($render_container.outerWidth())
    @renderer_height = Math.ceil($render_container.outerHeight())
    @application.renderer.resize(@renderer_width, @renderer_height)
    @initialize_map()

  initialize_application: () ->
    $render_container = $('#render-container')
    @offset = if $render_container.is(":visible") then $render_container.offset() else null
    @renderer_width = Math.ceil($render_container.outerWidth())
    @renderer_height = Math.ceil($render_container.outerHeight())
    @application = new PIXI.Application(@renderer_width, @renderer_height, {
      backgroundColor : 0x000000
    })
    $render_container.append(@application.view)

    @fps_meter = new FPSMeter($('#fps-container')[0], {
      theme: 'colorful'
    })

    new ResizeSensor($render_container, => @handle_resize())


  initialize_map: () ->
    @map_layers.remove_layers(@application.stage) if @map_layers?
    @map_layers = new starpeace.renderer.map.MapLayers(@, @client.game_state)
    @map_layers.add_layers(@application.stage)

  initialize: () ->
    @initialize_application() unless @application?

    land_manifest = @client.land_manifest_for_planet()
    map_texture = @client.asset_manager.map_id_texture[@client.planet.map_id]

    @client.game_state.game_map = starpeace.map.GameMap.from_texture(land_manifest, map_texture)
    @initialize_map()

    @client.game_state.loading = true
    setTimeout (=> @client.game_state.loading = false), 500

    @client.game_state.initialized = true
    @initialized = true

  tick: () ->
    @fps_meter.tickStart() if @fps_meter?

    unless @offset?
      $render_container = $('#render-container')
      @offset = $render_container.offset() if $render_container.is(":visible")
    @map_layers.refresh() if @map_layers?.should_refresh()

    @fps_meter.tick() if @fps_meter?

