
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_TILES = 25000

class LayerOverlay
  constructor: (@renderer, @game_state, @is_underlay) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      tint: true
      vertices: true
    })

    Logger.debug "configured map overlay layer for up to #{MAX_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    if @is_underlay
      counter.underlay = 0
    else
      counter.overlay = 0

  increment_counter: (counter, tile_info) ->
    if @is_underlay
      counter.underlay += 1
    else
      counter.overlay += 1

  sprite_for: (color, counter, x, y) ->
    sprite_index = if @is_underlay then counter.underlay else counter.overlay
    throw "maximum number of overlay particles reached" if sprite_index >= MAX_TILES

    texture = PIXI.utils.TextureCache['overlay']
    if sprite_index >= @sprites.length
      @sprites[sprite_index] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[sprite_index]) if @container?

    @sprites[sprite_index].tint = color
    @sprites[sprite_index]


  hide_sprites: (counter) ->
    from_index = if @is_underlay then counter.underlay else counter.overlay
    for index in [from_index...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000

export default LayerOverlay
