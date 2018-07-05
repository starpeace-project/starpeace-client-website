
###
global PIXI
global PIXI.extras
###

import Logger from '~/plugins/starpeace-client/logger.coffee'


MAX_GROUND_TILES = 10000

class LayerBuilding
  constructor: (@client, @renderer, @game_state) ->
    @static_sprites = []
    @animated_spites = []
    @container = new PIXI.particles.ParticleContainer(MAX_GROUND_TILES, {
      vertices: true
      position: true
      uvs: true
      tint: true
    })

    Logger.debug "configured map building layer for up to #{MAX_GROUND_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.building_static = 0
    counter.building_animated = 0

  increment_counter: (counter, tile_info) ->
    textures = @client.building_manager.building_textures[tile_info.building_info.key]
    return unless textures?.length
    if textures.length == 1
      counter.building_static += 1
    else
      counter.building_animated += 1

  sprite_for: (building_info, counter, x, y) ->
    throw "maximum number of building sprites reached" if (counter.building_static + counter.building_animated) >= MAX_GROUND_TILES

    textures = @client.building_manager.building_textures[building_info.key]
    return null unless textures?.length

    sprite = null
    if textures.length == 1
      if counter.building_static >= @static_sprites.length
        sprite = @static_sprites[counter.building_static] = new PIXI.Sprite(textures[0])
        @container.addChild(sprite)
      else
        sprite = @static_sprites[counter.building_static]
        sprite.texture = textures[0]
    else
      if counter.building_animated >= @animated_spites.length
        sprite = @animated_spites[counter.building_animated] = new PIXI.extras.AnimatedSprite(textures)
        sprite.animationSpeed = .2
        @container.addChild(sprite)
      else
        sprite = @animated_spites[counter.building_animated]
        sprite.textures = textures
      sprite.play()

    sprite

  hide_sprites: (counter) ->
    for index in [counter.building_static...@static_sprites.length]
      @static_sprites[index].visible = false
      @static_sprites[index].x = -1000
      @static_sprites[index].y = -1000
    for index in [counter.building_animated...@animated_spites.length]
      @animated_spites[index].stop()
      @animated_spites[index].visible = false
      @animated_spites[index].x = -1000
      @animated_spites[index].y = -1000


export default LayerBuilding
