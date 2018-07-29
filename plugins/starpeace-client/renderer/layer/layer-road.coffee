
###
global PIXI
###

import SpriteRoad from '~/plugins/starpeace-client/renderer/sprite/sprite-road.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_TILES = 25000

export default class LayerRoad
  constructor: (@game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      uvs: true
      vertices: true
    })

    Logger.debug "configured road layer for up to #{MAX_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.road = 0

  sprite_for: (road_info, counter, x, y, tile_width, tile_height) ->
    throw "maximum number of road particles reached" if counter.land >= MAX_TILES

    texture_id = if road_info.is_city then road_info.type.city_texture_id else road_info.type.country_texture_id
    return null unless texture_id?.length
    texture = PIXI.utils.TextureCache[texture_id]
    Logger.debug "no texture for road #{road_info.type}" unless texture?
    return null unless texture?

    if counter.road >= @sprites.length
      @sprites[counter.road] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[counter.road])
    else
      @sprites[counter.road].texture = texture

    new SpriteRoad(tile_width, tile_height, @sprites[counter.road])

  hide_sprites: (counter) ->
    for index in [counter.road...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000
