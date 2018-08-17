
###
global PIXI
###

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

SPRITE_BUFFER = 100000

export default class LayerCache
  constructor: (@container, @common_zorder_layer, @max_size, @is_animated) ->
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

  new_sprite: (render_state, options) ->
    render_state[@id] = 0 unless render_state[@id]?
    textures = if options.textures? then options.textures else [options.texture]

    if render_state[@id] < @sprite_count
      sprite = @sprite_pool[render_state[@id]]

      if @is_animated
        sprite.textures = textures
      else
        sprite.texture = textures[0]
    else
      throw "maximum number sprites reached" if @max_size > 0 && @sprite_count >= @max_size
      @sprite_count += 1
      sprite = @sprite_pool[render_state[@id]] = if @is_animated then new PIXI.extras.AnimatedSprite(textures) else new PIXI.Sprite(textures[0])
      sprite.parentLayer = @common_zorder_layer if @common_zorder_layer?
      @container.addChild(sprite)

    render_state[@id] += 1

    if @is_animated
      sprite.animationSpeed = if options.speed? then options.speed else .2
      sprite.gotoAndPlay(Math.floor(new Date().getTime() / 200) % textures.length)

    sprite
