
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_GROUND_TILES = 25000

class LayerGround
  constructor: (@renderer, @game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_GROUND_TILES, {
      uvs: true
      vertices: true
      tint: true
    })

    Logger.debug "configured map ground layer for up to #{MAX_GROUND_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.ground = 0

  increment_counter: (counter, tile_info) ->
    counter.ground += 1

  sprite_for: (counter, x, y) ->
    throw "maximum number of ground particles reached" if counter.ground >= MAX_GROUND_TILES

    texture = @game_state.game_map.ground_map.ground_texture_for(@game_state.current_season, y, x)
    if counter.ground >= @sprites.length
      @sprites[counter.ground] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[counter.ground]) if @container?
    else
      @sprites[counter.ground].texture = texture

    @sprites[counter.ground]


  hide_sprites: (counter) ->
    for index in [counter.ground...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000

export default LayerGround
