
###
global PIXI
###

import BuildingZone from '~/plugins/starpeace-client/map/building-zone.coffee'
import SpriteBuildingFootprint from '~/plugins/starpeace-client/renderer/sprite/sprite-building-footprint.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_TILES = 10000

export default class LayerBuildingFootprint
  constructor: (@building_manager, @game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      tint: true
      uvs: true
      vertices: true
    })
    @container.zIndex = 1

    Logger.debug "configured map building footprint layer for up to #{MAX_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.building_footprint = 0

  sprite_for: (building_info, counter, x, y, tile_width, tile_height) ->
    throw "maximum number of building footprint particles reached" if counter.building_footprint >= MAX_TILES

    metadata = @building_manager.building_metadata.buildings[building_info.key]
    building_zone = BuildingZone.TYPES[metadata.zone]
    texture = PIXI.utils.TextureCache["overlay.#{metadata.w}"]
    return unless texture?

    if counter.building_footprint >= @sprites.length
      @sprites[counter.building_footprint] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[counter.building_footprint])

    @sprites[counter.building_footprint].tint = if building_zone? then building_zone.color else BuildingZone.TYPES.RESERVED.color

    width = metadata.w * tile_width
    height = Math.ceil(texture.height * (width / texture.width))
    new SpriteBuildingFootprint(width, height, @sprites[counter.building_footprint])

  hide_sprites: (counter) ->
    for index in [counter.building_footprint...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000
