
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'

class LayerBuilding
  constructor: (@client, @renderer, @game_state) ->
    @static_sprites = []
    @animated_spites = []
    @container = new PIXI.Container()

    @group = new PIXI.display.Group(1, (sprite) ->
      sprite.zOrder = -10 * (sprite.y + sprite.height) + (sprite.x + sprite.width) * .5
    )
    @layer = new PIXI.display.Layer(@group)

    Logger.debug "configured map building layer"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.building = { static:0, animated:0 }

  increment_counter: (counter, tile_info) ->
    textures = @client.building_manager.building_textures[tile_info.building_info.key]
    return unless textures?.length
    if textures.length == 1
      counter.building.static += 1
    else
      counter.building.animated += 1

  sprite_for: (building_info, counter, x, y) ->
    textures = @client.building_manager.building_textures[building_info.key]
    return null unless textures?.length

    sprite = null
    if textures.length == 1
      if counter.building.static >= @static_sprites.length
        sprite = @static_sprites[counter.building.static] = new PIXI.Sprite(textures[0])
        sprite.parentGroup = @group
        @container.addChild(sprite)
      else
        sprite = @static_sprites[counter.building.static]
        sprite.texture = textures[0]
    else
      if counter.building.animated >= @animated_spites.length
        sprite = @animated_spites[counter.building.animated] = new PIXI.extras.AnimatedSprite(textures)
        sprite.parentGroup = @group
        sprite.animationSpeed = .2
        @container.addChild(sprite)
      else
        sprite = @animated_spites[counter.building.animated]
        sprite.textures = textures
      sprite.gotoAndPlay(Math.floor(new Date().getTime() / 200) % textures.length)

    sprite

  hide_sprites: (counter) ->
    for index in [counter.building.static...@static_sprites.length]
      @static_sprites[index].visible = false
      @static_sprites[index].x = -1000
      @static_sprites[index].y = -1000
    for index in [counter.building.animated...@animated_spites.length]
      @animated_spites[index].stop()
      @animated_spites[index].visible = false
      @animated_spites[index].x = -1000
      @animated_spites[index].y = -1000


export default LayerBuilding
