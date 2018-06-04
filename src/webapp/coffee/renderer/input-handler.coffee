

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.InputHandler = class InputHandler

  constructor: (@client, @renderer) ->

    @is_moving = false

    @last_x = -1
    @last_y = -1

    @auto_scroll = null
    @auto_scroll_x = 0
    @auto_scroll_y = 0

    start_moving = (event) =>
      @is_moving = true
      event = event?.data?.originalEvent
      return unless event?
      @last_x = Math.round(event.x)
      @last_y = Math.round(event.y)

    finish_moving = (event) =>
      @is_moving = false
      event = event?.data?.originalEvent
      return unless event?
      @last_x = Math.round(event.x)
      @last_y = Math.round(event.y)

    do_move = (event) =>
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

#       console.log "#{@last_x} #{@last_y}"

      @renderer.map_land_layer.needs_refresh = true if @renderer.map_land_layer?

    stop_auto_scroll = (event) =>
      clearInterval(@auto_scroll) if @auto_scroll?

    handle_auto_scroll = (event) =>
      if @is_moving
        clearInterval(@auto_scroll) if @auto_scroll?
        return

      event = event?.data?.originalEvent
      return unless event?
      event_x = Math.round(event.x)
      event_y = Math.round(event.y)

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
          if counter > 3
            @client.game_state.view_offset_x += (delta_x * 50)
            @client.game_state.view_offset_y += (delta_y * 50)
            @renderer.map_land_layer.needs_refresh = true if @renderer.map_land_layer?
        , 50)

      @auto_scroll_x = delta_x
      @auto_scroll_y = delta_y


    @renderer.application.renderer.plugins.interaction.on('mousedown', start_moving)
    @renderer.application.renderer.plugins.interaction.on('touchstart', start_moving)

    @renderer.application.renderer.plugins.interaction.on('mousemove', do_move)
    @renderer.application.renderer.plugins.interaction.on('touchmove', do_move)

    @renderer.application.renderer.plugins.interaction.on('mouseup', finish_moving)
    @renderer.application.renderer.plugins.interaction.on('mouseout', finish_moving)
    @renderer.application.renderer.plugins.interaction.on('mousecancel', finish_moving)
    @renderer.application.renderer.plugins.interaction.on('touchend', finish_moving)

    @renderer.application.renderer.plugins.interaction.on('mousemove', handle_auto_scroll)
    @renderer.application.renderer.plugins.interaction.on('touchmove', handle_auto_scroll)

    @renderer.application.renderer.plugins.interaction.on('mouseout', stop_auto_scroll)


    do_scale = (event) =>
      return unless event?.deltaY?

      before_scale = @client.game_state.game_scale
      @client.game_state.game_scale -= (event.deltaY / 600)
      @client.game_state.game_scale = 1.5 if @client.game_state.game_scale > 1.5
      @client.game_state.game_scale = 0.5 if @client.game_state.game_scale < 0.5

      scale_delta = @client.game_state.game_scale - before_scale
#       @client.game_state.view_offset_x -= (scale_delta * 3000)
#       @client.game_state.view_offset_y -= (scale_delta * 3000)

      @renderer.initialize_map() if @renderer.map_land_layer?

    document.addEventListener('mousewheel', do_scale, false)


