
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'


MAX_GROUND_TILES = 10000

class LayerBuilding
  constructor: (@client, @renderer, @game_state, @layer_group) ->
    @static_sprites = []
    @animated_spites = []
    # @container = new PIXI.Container()
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

  sprite_for: (building_info, counter, x, y) ->
    throw "maximum number of building sprites reached" if (counter.static + counter.animated) >= MAX_GROUND_TILES

    textures = @client.building_manager.building_textures[building_info.key]
    return null unless textures?.length

    sprite = null
    if textures.length == 1
      if counter.static >= @static_sprites.length
        sprite = @static_sprites[counter.static] = new PIXI.Sprite(textures[0])
        sprite.parentGroup = @layer_group
        @container.addChild(sprite)
      else
        sprite = @static_sprites[counter.static]
        sprite.texture = textures[0]
    else
      if counter.animated >= @animated_spites.length
        sprite = @animated_spites[counter.animated] = new PIXI.extras.AnimatedSprite(textures)
        sprite.parentGroup = @layer_group
        sprite.animationSpeed = .2
        @container.addChild(sprite)
      else
        sprite = @animated_spites[counter.animated]
        sprite.textures = textures
      sprite.play()

    sprite

  hide_sprites: (counter) ->
    for index in [counter.static...@static_sprites.length]
      @static_sprites[index].visible = false
      @static_sprites[index].x = -1000
      @static_sprites[index].y = -1000
    for index in [counter.animated...@animated_spites.length]
      @animated_spites[index].stop()
      @animated_spites[index].visible = false
      @animated_spites[index].x = -1000
      @animated_spites[index].y = -1000


export default LayerBuilding
