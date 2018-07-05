
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_GROUND_TILES = 10000

class LayerTree
  constructor: (@renderer, @game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_GROUND_TILES, {
      uvs: true
      vertices: true
      tint: true
    })

    Logger.debug "configured map tree layer for up to #{MAX_GROUND_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.tree = 0

  increment_counter: (counter, tile_info) ->
    counter.tree += 1

  sprite_for: (counter, x, y) ->
    throw "maximum number of tree particles reached" if counter.tree >= MAX_GROUND_TILES

    texture = @game_state.game_map.ground_map.tree_texture_for(@game_state.current_season, y, x)
    return null unless texture?

    if counter.tree >= @sprites.length
      @sprites[counter.tree] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[counter.tree]) if @container?
    else
      @sprites[counter.tree].texture = texture

    @sprites[counter.tree]


  hide_sprites: (counter) ->
    for index in [counter.tree...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000

export default LayerTree
