
export default class MiniMapInputHandler
  constructor: (@mini_map_renderer, render_container) ->
    render_container.addEventListener('pointerdown', (event) => @map_drag_start(event))
    render_container.addEventListener('pointermove', (event) => @map_drag_move(event))
    render_container.addEventListener('pointerup', (event) => @map_drag_end(event))
    render_container.addEventListener('pointerupoutside', (event) => @map_drag_end(event))

  map_drag_start: (event) ->
    return unless event? && event.isPrimary

    @start_x = @last_x = Math.round(event.offsetX)
    @start_y = @last_y = Math.round(event.offsetY)
    @dragging = true

  map_drag_end: (event) ->
    return unless @dragging && event? && event.isPrimary

    @last_x = Math.round(event.offsetX)
    @last_y = Math.round(event.offsetY)
    @dragging = false

    @mini_map_renderer.recenterAt(@last_x, @last_y) if @last_x == @start_x && @last_y == @start_y

  map_drag_move: (event) ->
    return unless @dragging && event? && event.isPrimary

    event_x = Math.round(event.offsetX)
    event_y = Math.round(event.offsetY)

    delta_x = if @last_x >= 0 then @last_x - event_x else 0
    delta_y = if @last_y >= 0 then @last_y - event_y else 0
    @last_x = event_x
    @last_y = event_y

    @mini_map_renderer.offset(delta_x, delta_y) unless delta_x == 0 && delta_y == 0
