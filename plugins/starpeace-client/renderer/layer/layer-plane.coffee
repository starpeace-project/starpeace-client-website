
###
global PIXI
###

import SpritePlane from '~/plugins/starpeace-client/renderer/sprite/sprite-plane.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class LayerPlane
  constructor: (@client, @renderer, @game_state) ->
    @container = new PIXI.particles.ParticleContainer(10, {
      uvs: true
      vertices: true
      tint: true
    })
    @container.zIndex = 5

    @client.game_state.plane_sprite = @add_sprite_from_existing(@game_state.plane_sprite) if @game_state.plane_sprite?
    Logger.debug "configured map plane layer"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  add_sprite_from_existing: (existing_sprite) ->
    @add_sprite(existing_sprite.plane_info, existing_sprite.direction, existing_sprite.velocity,
        existing_sprite.current_map_x, existing_sprite.current_map_y, existing_sprite.target_map_x, existing_sprite.target_map_y)

  add_sprite: (plane_info, direction, velocity, source_map_x, source_map_y, target_map_x, target_map_y) ->
    textures = @client.plane_manager.plane_textures[plane_info.key]
    return null unless textures?.length

    width = @game_state.game_scale * textures[0].width
    height = @game_state.game_scale * textures[0].height

    sprite = new PIXI.extras.AnimatedSprite(textures)
    @container.addChild(sprite)

    sprite.visible = false
    sprite.x = -1000
    sprite.y = -1000
    sprite.width = width
    sprite.height = height

    sprite.animationSpeed = .2
    sprite.gotoAndPlay(Math.floor(new Date().getTime() / 200) % textures.length)

    new SpritePlane(width, height, sprite, plane_info, direction, velocity, source_map_x, source_map_y, target_map_x, target_map_y)

  refresh_sprites: () ->
    return unless @game_state.plane_sprite?.sprite?.texture?

    viewport = @renderer.viewport()
    view_center = viewport.map_center()
    iso = viewport.map_to_iso(@game_state.game_scale * @game_state.plane_sprite.current_map_x, @game_state.game_scale * @game_state.plane_sprite.current_map_y)
    canvas = viewport.iso_to_canvas(iso.i_exact, iso.j_exact, view_center)

    width = @game_state.game_scale * @game_state.plane_sprite.sprite.texture.width
    height = @game_state.game_scale * @game_state.plane_sprite.sprite.texture.height

    is_visible = (canvas.x > -width && canvas.x <= viewport.canvas_width) && (canvas.y > -height && canvas.y <= viewport.canvas_height)
    current_time = new Date().getTime()
    if !is_visible && (@game_state.plane_sprite.is_at_target() || @game_state.plane_sprite.last_shown > 0 && (current_time - @game_state.plane_sprite.last_shown) > 3000)
      @container.removeChild(@game_state.plane_sprite.sprite)
      @game_state.plane_sprite = null
      return

    @game_state.plane_sprite.last_shown = current_time if is_visible

    @game_state.plane_sprite.sprite.visible = is_visible
    @game_state.plane_sprite.sprite.x = canvas.x - width * 0.5
    @game_state.plane_sprite.sprite.y = canvas.y
    @game_state.plane_sprite.sprite.width = width
    @game_state.plane_sprite.sprite.height = height

    @game_state.plane_sprite.current_map_x += @game_state.plane_sprite.velocity.x
    @game_state.plane_sprite.current_map_y += @game_state.plane_sprite.velocity.y
