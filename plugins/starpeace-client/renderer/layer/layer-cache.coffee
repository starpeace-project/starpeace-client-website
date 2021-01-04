
import * as PIXI from 'pixi.js'

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

SPRITE_BUFFER = 100000

export default class LayerCache
  constructor: (@container, @common_zorder_layer, @max_size, @is_animated, @pointer_events) ->
    @id = Utils.uuid()

    @sprite_count = 0
    @sprite_pool = new Array(SPRITE_BUFFER)

  clear_cache: (render_state) ->
    count = render_state[@id] || 0
    return unless count < @sprite_count

    for index in [count...@sprite_count]
      break unless @sprite_pool[index]
      @sprite_pool[index].visible = false
      @sprite_pool[index].x = -1000
      @sprite_pool[index].y = -1000
      @sprite_pool[index].click_callback = null

  new_sprite: (render_state, options) ->
    render_state[@id] = 0 unless render_state[@id]?
    textures = _.compact(if options.textures? then options.textures else [options.texture])
    textures.push PIXI.Texture.EMPTY unless textures.length

    if render_state[@id] < @sprite_count
      sprite = @sprite_pool[render_state[@id]]

      if @is_animated
        sprite.textures = textures
      else
        sprite.texture = textures[0]
    else
      throw "maximum number sprites reached" if @max_size > 0 && @sprite_count >= @max_size
      @sprite_count += 1
      sprite = @sprite_pool[render_state[@id]] = if @is_animated then new PIXI.AnimatedSprite(textures) else new PIXI.Sprite(textures[0])
      if @pointer_events
        sprite.interactive = true
        sprite.interactiveChildren = false

        sprite.on('pointerdown', (event) ->
          return unless event.currentTarget.click_callback?

          event.currentTarget.event_pointer_down_x = Math.round(event.data?.global?.x || 0)
          event.currentTarget.event_pointer_down_y = Math.round(event.data?.global?.y || 0)
        )
        sprite.on('pointerup', (event) =>
          return unless event.currentTarget.click_callback?

          delta_x = Math.round(event.data?.global?.x || 0) - (event.currentTarget.event_pointer_down_x || 0)
          delta_y = Math.round(event.data?.global?.y || 0) - (event.currentTarget.event_pointer_down_y || 0)
          return if delta_x > 0 || delta_y > 0

          if event.currentTarget.click_callback(event.data?.button == 0, event.data?.button == 2)
            event.data?.originalEvent?.preventDefault()
            event.data?.originalEvent?.stopPropagation()
            event.stopPropagation()
          false
        )
      @container.addChild(sprite)

    render_state[@id] += 1

    if @pointer_events
      sprite.hitArea = if options.hit_area then options.hit_area else null
      sprite.click_callback = if options.click_callback? then options.click_callback else null

    if @is_animated
      sprite.animationSpeed = if options.speed? then options.speed else .2
      sprite.gotoAndPlay(Math.floor(new Date().getTime() / 200) % textures.length)

    sprite
