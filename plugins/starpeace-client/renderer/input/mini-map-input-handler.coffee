
export default class MiniMapInputHandler
  constructor: (@mini_map_renderer) ->
    @mini_map_renderer.application.stage.addEventListener('pointerdown', (event) => @map_drag_start(event))
    @mini_map_renderer.application.stage.addEventListener('pointermove', (event) => @map_drag_move(event))
    @mini_map_renderer.application.stage.addEventListener('pointerup', (event) => @map_drag_end(event))
    @mini_map_renderer.application.stage.addEventListener('pointerupoutside', (event) => @map_drag_end(event))

  map_drag_start: (event) ->
    event = event?.data
    return unless event? && event.isPrimary

    @start_x = @last_x = Math.round(event.global.x)
    @start_y = @last_y = Math.round(event.global.y)
    @dragging = true

  map_drag_end: (event) ->
    event = event?.data
    return unless @dragging && event? && event.isPrimary

    @last_x = Math.round(event.global.x)
    @last_y = Math.round(event.global.y)
    @dragging = false

    @mini_map_renderer.recenter_at(@last_x, @last_y) if @last_x == @start_x && @last_y == @start_y

  map_drag_move: (event) ->
    event = event?.data
    return unless @dragging && event? && event.isPrimary

    event_x = Math.round(event.global.x)
    event_y = Math.round(event.global.y)

    delta_x = if @last_x >= 0 then @last_x - event_x else 0
    delta_y = if @last_y >= 0 then @last_y - event_y else 0
    @last_x = event_x
    @last_y = event_y

    @mini_map_renderer.offset(delta_x, delta_y) unless delta_x == 0 && delta_y == 0
