import { markRaw } from 'vue';

import MetadataLand from '~/plugins/starpeace-client/land/metadata-land.coffee'
import EventListener from '~/plugins/starpeace-client/state/event-listener'

CAMERA_MIN_ZOOM = .25
CAMERA_MAX_ZOOM = 1.5

export default class CameraState
  constructor: (@client_state) ->
    @event_listener = markRaw(new EventListener())

    @view_offset_x = 0
    @view_offset_y = 0
    @game_scale = 0.75

    renderer_width = 100 # dummy value
    renderer_height = 100 # dummy value
    @canvas_width = Math.ceil(renderer_width || 0)
    @canvas_height = Math.ceil(renderer_height || 0)
    @half_canvas_width = Math.ceil(@canvas_width * 0.5)
    @half_canvas_height = Math.ceil(@canvas_height * 0.5)

    @tile_width = Math.ceil(MetadataLand.DEFAULT_TILE_WIDTH * @game_scale)
    @tile_height = Math.ceil(MetadataLand.DEFAULT_TILE_HEIGHT * @game_scale)
    @half_tile_width = Math.ceil(@tile_width / 2)
    @half_tile_height = Math.ceil(@tile_height / 2)

    @offset = Math.ceil(Math.sqrt(@half_canvas_width * @half_canvas_width + @half_canvas_height * @half_canvas_height))
    @omega = Math.atan2(@canvas_width / 4, @canvas_height / 4)

  subscribe_viewport_listener: (listener_callback) -> @event_listener.subscribe('interface.viewport', listener_callback)
  notify_viewport_listeners: () -> @event_listener.notify_listeners('interface.viewport')

  reset_state: () ->
    @view_offset_x = 0
    @view_offset_y = 0
    @game_scale = 0.75

  resize: (renderer_width, renderer_height) ->
    @canvas_width = Math.ceil(renderer_width || 0)
    @canvas_height = Math.ceil(renderer_height || 0)
    @half_canvas_width = Math.ceil(@canvas_width * 0.5)
    @half_canvas_height = Math.ceil(@canvas_height * 0.5)

    @refresh()
    @notify_viewport_listeners()

  refresh: () ->
    @tile_width = Math.ceil(MetadataLand.DEFAULT_TILE_WIDTH * @game_scale)
    @tile_height = Math.ceil(MetadataLand.DEFAULT_TILE_HEIGHT * @game_scale)
    @half_tile_width = Math.ceil(@tile_width / 2)
    @half_tile_height = Math.ceil(@tile_height / 2)

    @offset = Math.ceil(Math.sqrt(@half_canvas_width * @half_canvas_width + @half_canvas_height * @half_canvas_height))
    @omega = Math.atan2(@canvas_width / 4, @canvas_height / 4)


  position_from_top_left: (x, y) ->
    top_left = @top_left()
    {
      x: Math.round(top_left.x + x + @half_tile_width)
      y: Math.round(top_left.y + y + @half_tile_height)
    }


  recenterAt: (i, j) ->
    y = (i + j) * @half_tile_height
    x = (i - j) * @half_tile_width

    @view_offset_x = (x - @half_canvas_width + @offset * Math.sin(@omega)) / @game_scale
    @view_offset_y = (y - @half_canvas_height + @offset * Math.cos(@omega)) / @game_scale

    # @notify_viewport_listeners()

  center: () ->
    x = @game_scale * @view_offset_x
    y = @game_scale * @view_offset_y
    {
      x: Math.round(x)
      y: Math.round(y)
      x_exact: x
      y_exact: y
    }


  top_left_at: (i, j) ->
    y = (i + j) * @half_tile_height
    x = (i - j) * @half_tile_width

    @view_offset_x = (x + @offset * Math.sin(@omega)) / @game_scale
    @view_offset_y = (y + @offset * Math.cos(@omega)) / @game_scale

    # @notify_viewport_listeners()

  top_left: () ->
    x = @game_scale * @view_offset_x - @offset * Math.sin(@omega)
    y = @game_scale * @view_offset_y - @offset * Math.cos(@omega)
    {
      x: Math.round(x)
      y: Math.round(y)
      x_exact: x
      y_exact: y
    }


  map_to_iso: (x, y) ->
    y_ratio = y / @half_tile_height
    x_ratio = x / @half_tile_width
    i = (y_ratio + x_ratio) * 0.5
    j = (y_ratio - x_ratio) * 0.5
    {
      i: Math.round(i)
      j: Math.round(j)
      i_exact: i
      j_exact: j
    }

  iso_to_canvas: (i, j, center) ->
    {
      x: Math.round((i - j) * @half_tile_width - @tile_width - center.x)
      y: Math.round((i + j) * @half_tile_height - @tile_height - center.y)
    }

  tile_size_x: (percent) -> @tile_width * percent
  tile_size_y: (percent) -> @tile_height * percent
  with_scale: (value) -> @game_scale * value


  camera_adjust_scale: (delta) ->
    before_scale = @game_scale
    @game_scale -= delta
    @game_scale = CAMERA_MAX_ZOOM if @game_scale > CAMERA_MAX_ZOOM
    @game_scale = CAMERA_MIN_ZOOM if @game_scale < CAMERA_MIN_ZOOM
    @refresh() unless @game_scale == before_scale

  camera_zoom_in: () -> @camera_adjust_scale(-0.25)
  camera_zoom_out: () -> @camera_adjust_scale(0.25)

  pan_camera: (delta_x, delta_y) ->
    @view_offset_x += (delta_x / @game_scale) unless delta_x == 0
    @view_offset_y += (delta_y / @game_scale) unless delta_y == 0
    # FIXME: TODO: might want to notify listeners
