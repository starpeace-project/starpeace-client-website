
###
global PIXI
###

import SpriteLand from '~/plugins/starpeace-client/renderer/sprite/sprite-land.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_TILES = 25000

export default class LayerLand
  constructor: (@renderer, @game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      uvs: true
      vertices: true
      tint: true
    })

    Logger.debug "configured map land layer for up to #{MAX_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.land = 0

  sprite_for: (counter, x, y, tile_width, tile_height) ->
    throw "maximum number of land particles reached" if counter.land >= MAX_TILES

    texture = @game_state.game_map.ground_map.ground_texture_for(@game_state.current_season, y, x)
    if counter.land >= @sprites.length
      @sprites[counter.land] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[counter.land])
    else
      @sprites[counter.land].texture = texture

    new SpriteLand(tile_width, tile_height, @sprites[counter.land])

  hide_sprites: (counter) ->
    for index in [counter.land...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000
