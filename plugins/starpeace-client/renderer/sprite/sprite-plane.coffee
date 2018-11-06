
###
global PIXI
###

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class SpritePlane extends Sprite
  constructor: (@textures, @flight_plan) ->
    super()

    @last_shown = -1

    @current_map_x = @flight_plan.source_map_x
    @current_map_y = @flight_plan.source_map_y

    @is_done = false

  width: (viewport) ->
    unless @textures[0]?
      Logger.warn "plane sprite unexpectedly has no texture"
      console.log @
      return 0
    viewport.with_scale(@textures[0].width)
  height: (viewport) -> viewport.with_scale(@textures[0].height)

  render: (sprite, viewport) ->
    return unless @sprite? && !@is_done
    unless @sprite?.texture?
      # texture fails to load sometimes
      @is_done = true
      return

    view_center = viewport.map_center()
    iso = viewport.map_to_iso(viewport.with_scale(@current_map_x), viewport.with_scale(@current_map_y))
    canvas = viewport.iso_to_canvas(iso.i_exact, iso.j_exact, view_center)

    width = @width(viewport)
    height = @height(viewport)

    is_visible = (canvas.x > -width && canvas.x <= viewport.canvas_width) && (canvas.y > -height && canvas.y <= viewport.canvas_height)
    current_time = new Date().getTime()
    if !is_visible && (@is_at_target() || @last_shown > 0 && (current_time - @last_shown) > 3000)
      @is_done = true
      return

    sprite.visible = is_visible
    sprite.x = canvas.x - width * 0.5
    sprite.y = canvas.y
    sprite.width = width
    sprite.height = height

    @last_shown = current_time if is_visible
    @current_map_x += @flight_plan.velocity.x
    @current_map_y += @flight_plan.velocity.y

  is_at_target: () ->
    diff_x = @current_map_x - @flight_plan.target_map_x
    diff_y = @current_map_y - @flight_plan.target_map_y

    return diff_x >= 0 && diff_y >= 0 if @flight_plan.direction == 'se'
    return diff_x <= 0 && diff_y <= 0 if @flight_plan.direction == 'nw'

    return diff_x <= 0 && diff_y >= 0 if @flight_plan.direction == 'sw'
    return diff_x <= 0 && diff_y <= 0 if @flight_plan.direction == 'ne'

    return diff_x >= 0 && diff_y <= 0 if @flight_plan.direction == 'e'
    return diff_x <= 0 && diff_y <= 0 if @flight_plan.direction == 'n'

    return diff_x >= 0 && diff_y >= 0 if @flight_plan.direction == 's'
    return diff_x <= 0 && diff_y >= 0 if @flight_plan.direction == 'w'

    false
