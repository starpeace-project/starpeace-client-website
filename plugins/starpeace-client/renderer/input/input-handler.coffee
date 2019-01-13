
ZOOM_DISABLED = false
AUTO_SCROLL_DISABLED = true

export default class InputHandler
  constructor: (@managers, @renderer, @renderer_dom, @client_state) ->
    @is_moving = false

    @last_x = -1
    @last_y = -1

    @auto_scroll = null
    @auto_scroll_x = 0
    @auto_scroll_y = 0


    @renderer_dom.addEventListener('pointerdown', ((event) => @primary_mouse_down(event)), false)
    @renderer_dom.addEventListener('pointerup', ((event) => @primary_mouse_up(event)), false)

    @renderer_dom.addEventListener('pointermove', ((event) => @pointer_move(event)), false)
    @renderer_dom.addEventListener('pointerout', ((event) => @pointer_cancel(event)), false)
    @renderer_dom.addEventListener('pointercancel', ((event) => @pointer_cancel(event)), false)

    @renderer_dom.addEventListener('contextmenu', ((event) => @secondary_mouse_up_over_renderer(event)), false)
    document.addEventListener('contextmenu', ((event) => @secondary_mouse_up_outside_renderer(event)), false)

    @renderer_dom.addEventListener('pointermove', ((event) => @handle_auto_scroll(event)), false)
    @renderer_dom.addEventListener('pointerout', ((event) => @stop_auto_scroll(event)), false)

    @renderer_dom.addEventListener('mousewheel', ((event) => @do_scale(event)), false)


  within_screen: (x, y) ->
    lhs_min = @renderer.offset?.left || 0
    rhs_max = lhs_min + @renderer.renderer_width

    ths_min = @renderer.offset?.top || 0
    bhs_max = ths_min + @renderer.renderer_height

    x >= lhs_min && x <= rhs_max && y >= ths_min && y <= bhs_max


  secondary_mouse_up_over_renderer: (event) ->
    event.preventDefault()
    event.stopPropagation()
    false

  secondary_mouse_up_outside_renderer: (event) ->
    unless process?.env?.NODE_ENV == 'development'
      event.preventDefault()
      event.stopPropagation()
      false


  primary_mouse_down: (event) ->
    return unless @client_state.initialized && @client_state?.workflow_status == 'ready'

    @client_state.interface.is_mouse_primary_down = true
    @client_state.interface.start_mouse_x = @client_state.interface.last_mouse_x = Math.round(event.offsetX)
    @client_state.interface.start_mouse_y = @client_state.interface.last_mouse_y = Math.round(event.offsetY)

    #event.preventDefault()
    #event.stopPropagation()

  primary_mouse_up: (event) ->
    is_right_click = event.which == 3 || event.button == 2
    return unless @client_state.initialized && @client_state?.workflow_status == 'ready'

    if @client_state.interface.is_mouse_primary_down
      @client_state.interface.is_mouse_primary_down = false
      @client_state.interface.last_mouse_x = Math.round(event.offsetX)
      @client_state.interface.last_mouse_y = Math.round(event.offsetY)

      if !event.stopped && @client_state.interface.last_mouse_x == @client_state.interface.start_mouse_x && @client_state.interface.last_mouse_y == @client_state.interface.start_mouse_y
        unless is_right_click
          if @client_state.interface.construction_building_id?.length
            @managers.building_manager.construct_building() if @client_state.can_construct_building()
            @client_state.interface.construction_building_id = null

          else if @client_state.interface.selected_building_id?.length
            @client_state.interface.selected_building_id = null

        else
          @client_state.interface.construction_building_id = null if @client_state.interface.construction_building_id?

    event.preventDefault()
    event.stopPropagation()
    false


  pointer_move: (event) ->
    return unless @client_state.initialized && @client_state?.workflow_status == 'ready'

    event_x = Math.round(event.offsetX)
    event_y = Math.round(event.offsetY)

    if @client_state.interface.construction_building_id?
      position = @client_state.camera.position_from_top_left(event_x, event_y)
      iso_position = @client_state.camera.map_to_iso(position.x, position.y)
      @client_state.interface.construction_building_map_x = iso_position.i
      @client_state.interface.construction_building_map_y = iso_position.j


    if @client_state.interface.is_mouse_primary_down
      delta_x = if @client_state.interface.last_mouse_x >= 0 then @client_state.interface.last_mouse_x - event_x else 0
      delta_y = if @client_state.interface.last_mouse_y >= 0 then @client_state.interface.last_mouse_y - event_y else 0
      @client_state.interface.last_mouse_x = event_x
      @client_state.interface.last_mouse_y = event_y

      @client_state.camera.pan_camera(delta_x, delta_y)


  pointer_cancel: (event) ->
    return unless @client_state.initialized && @client_state?.workflow_status == 'ready'

    if @client_state.interface.is_mouse_primary_down
      @client_state.interface.is_mouse_primary_down = false

    event.preventDefault()
    event.stopPropagation()
    false



  stop_auto_scroll: (event) ->
    clearInterval(@auto_scroll) if @auto_scroll?

  handle_auto_scroll: (event) ->
    return if AUTO_SCROLL_DISABLED
    if @is_moving
      clearInterval(@auto_scroll) if @auto_scroll?
      return

    event = event?.data?.originalEvent
    return unless event?
    event_x = Math.round(event.clientX)
    event_y = Math.round(event.clientY)

    return unless @client_state?.renderer_initialized && @within_screen(event_x, event_y)

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
        @client_state.interface.pan_camera(delta_x * 25, delta_y * 25) if counter > 6
      , 25)

    @auto_scroll_x = delta_x
    @auto_scroll_y = delta_y


  do_scale: (event) ->
    return unless @client_state.initialized && @client_state?.workflow_status == 'ready' && event?.deltaY?

    if event.deltaY > 0
      @client_state.camera.camera_zoom_out()
    else if event.deltaY < 0
      @client_state.camera.camera_zoom_in()
