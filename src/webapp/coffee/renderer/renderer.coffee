

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.Renderer = class Renderer

  constructor: () ->
    $render_container = $('#render-container')
    @application = new PIXI.Application($render_container.outerWidth(), $render_container.outerHeight(), {
      backgroundColor : 0x00ffff
    })
    $render_container.append(@application.view)

    new ResizeSensor($render_container, => @handle_resize())

  initialize: () ->
    container = new PIXI.Container()
    @application.stage.addChild(container)

  handle_resize: () ->
    $render_container = $('#render-container')
    @application.renderer.resize($render_container.outerWidth(), $render_container.outerHeight())

