
###
global PIXI
###

import SpriteOverlay from '~/plugins/starpeace-client/renderer/sprite/sprite-overlay.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_TILES = 25000

export default class LayerOverlay
  constructor: (@game_state, @is_underlay) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      tint: true
      vertices: true
    })
    @container.zIndex = if @is_underlay then 0 else 2

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

  sprite_for: (color, counter, x, y, tile_width, tile_height) ->
    sprite_index = if @is_underlay then counter.underlay else counter.overlay
    throw "maximum number of overlay particles reached" if sprite_index >= MAX_TILES

    texture = PIXI.utils.TextureCache['overlay.1']
    return unless texture?

    if sprite_index >= @sprites.length
      @sprites[sprite_index] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[sprite_index])
    @sprites[sprite_index].tint = color

    new SpriteOverlay(tile_width, tile_height, @sprites[sprite_index], @is_underlay)

  hide_sprites: (counter) ->
    from_index = if @is_underlay then counter.underlay else counter.overlay
    for index in [from_index...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000
