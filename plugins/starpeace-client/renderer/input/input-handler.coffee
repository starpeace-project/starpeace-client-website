
ZOOM_DISABLED = false
AUTO_SCROLL_DISABLED = true

class InputHandler
  constructor: (@game_state, @menu_state, @camera_manager, @renderer) ->
    @initialized = false

    @is_moving = false

    @last_x = -1
    @last_y = -1

    @auto_scroll = null
    @auto_scroll_x = 0
    @auto_scroll_y = 0


  initialize: () ->
    return unless @renderer?.initialized && !@initialized

    within_screen = (x, y) =>
      lhs_min = @renderer.offset?.left || 0
      rhs_max = lhs_min + @renderer.renderer_width

      ths_min = @renderer.offset?.top || 0
      bhs_max = ths_min + @renderer.renderer_height

      x >= lhs_min && x <= rhs_max && y >= ths_min && y <= bhs_max

    start_moving = (event) =>
      @is_moving = true
      event = event?.data
      return unless @renderer?.initialized && event? && event.isPrimary
      @last_x = Math.round(event.global.x)
      @last_y = Math.round(event.global.y)

    finish_moving = (event) =>
      @is_moving = false
      event = event?.data
      return unless @renderer?.initialized && event? && event.isPrimary
      @last_x = Math.round(event.global.x)
      @last_y = Math.round(event.global.y)

    do_move = (event) =>
      event = event?.data
      return unless @is_moving && @renderer?.initialized && event? && event.isPrimary

      event_x = Math.round(event.global.x)
      event_y = Math.round(event.global.y)

      delta_x = if @last_x >= 0 then @last_x - event_x else 0
      delta_y = if @last_y >= 0 then @last_y - event_y else 0
      @last_x = event_x
      @last_y = event_y

      @camera_manager.pan_camera(delta_x / @game_state.game_scale, delta_y / @game_state.game_scale)

    stop_auto_scroll = (event) =>
      clearInterval(@auto_scroll) if @auto_scroll?

    handle_auto_scroll = (event) =>
      return if AUTO_SCROLL_DISABLED
      if @is_moving
        clearInterval(@auto_scroll) if @auto_scroll?
        return

      event = event?.data?.originalEvent
      return unless event?
      event_x = Math.round(event.clientX)
      event_y = Math.round(event.clientY)

      return unless @renderer?.initialized && within_screen(event_x, event_y)

      lhs_min = @renderer.offset?.left || 0
      lhs_max = lhs_min + 100
      rhs_max = lhs_min + @renderer.renderer_width
      rhs_min = rhs_max - 100

      ths_min = @renderer.offset?.top || 0
      ths_max = ths_min + 50
      bhs_max = ths_min + @renderer.renderer_height
      bhs_min = bhs_max - 50

      delta_x = if event_x > lhs_min && event_x < lhs_max then -1 else if event_x > rhs_min && event_x < rhs_max then 1 else 0
      delta_y = if event_y > ths_min && event_y < ths_max then -1 else if event_y > bhs_min && event_y < bhs_max then 1 else 0

      if delta_x == 0 && delta_y == 0
        clearInterval(@auto_scroll) if @auto_scroll?
        @auto_scroll = null
      else if @auto_scroll_x != delta_x || @auto_scroll_y != delta_y
        clearInterval(@auto_scroll) if @auto_scroll?
        counter = 0
        @auto_scroll = setInterval(=>
          counter += 1
          @camera_manager.pan_camera(delta_x * 25, delta_y * 25) if counter > 6
        , 25)

      @auto_scroll_x = delta_x
      @auto_scroll_y = delta_y


    @renderer.application.renderer.plugins.interaction.on('pointerdown', start_moving)
    @renderer.application.renderer.plugins.interaction.on('pointermove', do_move)
    @renderer.application.renderer.plugins.interaction.on('pointerup', finish_moving)
    @renderer.application.renderer.plugins.interaction.on('pointerout', finish_moving)
    @renderer.application.renderer.plugins.interaction.on('pointercancel', finish_moving)

    @renderer.application.renderer.plugins.interaction.on('pointermove', handle_auto_scroll)
    @renderer.application.renderer.plugins.interaction.on('pointerout', stop_auto_scroll)


    do_scale = (event) =>
      return true if ZOOM_DISABLED || @menu_state.is_any_menu_open()
      return unless event?.deltaY?
      return unless within_screen(event.clientX, event.clientY)

      if event.deltaY > 0
        @camera_manager.zoom_out()
      else if event.deltaY < 0
        @camera_manager.zoom_in()

    document.addEventListener('mousewheel', do_scale, false)

    @initialized = true

export default InputHandler
