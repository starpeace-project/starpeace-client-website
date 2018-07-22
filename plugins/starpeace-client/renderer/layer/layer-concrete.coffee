
###
global PIXI
###

import Concrete from '~/plugins/starpeace-client/map/types/concrete.coffee'
import SpriteConcrete from '~/plugins/starpeace-client/renderer/sprite/sprite-concrete.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_TILES = 10000

export default class LayerConcrete
  constructor: (@game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      uvs: true
      vertices: true
    })

    Logger.debug "configured map concrete layer for up to #{MAX_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.concrete = 0

  sprite_for: (concrete_info, counter, tile_width, tile_height) ->
    throw "maximum number of concrete particles reached" if counter.concrete >= MAX_TILES

    return null unless concrete_info.type?.texture_id?.length
    texture = PIXI.utils.TextureCache[concrete_info.type?.texture_id]
    Logger.debug "no texture for #{concrete_info.type?.texture_id}" unless texture?
    return null unless texture?

    if counter.concrete >= @sprites.length
      @sprites[counter.concrete] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[counter.concrete])
    else
      @sprites[counter.concrete].texture = texture

    offset_y = if concrete_info.type.is_platform then Math.round(@game_state.game_scale * 18) else 0
    new SpriteConcrete(tile_width, Math.ceil(texture.height * (tile_width / texture.width)), @sprites[counter.concrete], false, offset_y)

  hide_sprites: (counter) ->
    for index in [counter.concrete...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000
