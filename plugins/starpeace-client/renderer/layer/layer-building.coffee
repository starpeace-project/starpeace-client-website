
###
global PIXI
###

import Concrete from '~/plugins/starpeace-client/map/types/concrete.coffee'
import SpriteBuilding from '~/plugins/starpeace-client/renderer/sprite/sprite-building.coffee'
import SpriteConcrete from '~/plugins/starpeace-client/renderer/sprite/sprite-concrete.coffee'
import SpriteEffect from '~/plugins/starpeace-client/renderer/sprite/sprite-effect.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class LayerBuilding
  constructor: (@common_zorder_group, @building_manager, @effect_manager, @game_state, @ui_state) ->
    @static_sprites = []
    @animated_sprites = []
    @effect_sprites = []
    @container = new PIXI.Container()

    Logger.debug "configured map building layer"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.building = { static:0, animated:0, effect:0 }

  static_sprite: (counter_index, texture) ->
    if counter_index >= @static_sprites.length
      sprite = @static_sprites[counter_index] = new PIXI.Sprite(texture)
      sprite.parentGroup = @common_zorder_group
      @container.addChild(sprite)
      sprite
    else
      sprite = @static_sprites[counter_index]
      sprite.texture = texture
      sprite

  animated_sprite: (sprite_container, counter_index, speed, textures) ->
    sprite = null
    if counter_index >= sprite_container.length
      sprite = sprite_container[counter_index] = new PIXI.extras.AnimatedSprite(textures)
      sprite.parentGroup = @common_zorder_group
      @container.addChild(sprite)
    else
      sprite = sprite_container[counter_index]
      sprite.textures = textures
    sprite.animationSpeed = speed
    sprite.gotoAndPlay(Math.floor(new Date().getTime() / 200) % textures.length)
    sprite

  concrete_sprite_for: (concrete_info, counter, tile_width, tile_height) ->
    return null unless concrete_info.type == Concrete.TYPES.CENTER_TREEABLE
    texture = PIXI.utils.TextureCache['concrete.c.plant']
    Logger.debug("unable to find concrete texture <concrete.c.plant>") unless texture?
    return null unless texture?
    sprite = @static_sprite(counter.building.static, texture)
    sprite.map_half_height = Math.round(.5 * tile_height)
    new SpriteConcrete(tile_width, Math.ceil(texture.height * (tile_width / texture.width)), sprite, true, 0)

  sprite_for: (building_info, counter, tile_width, tile_height) ->
    textures = @building_manager.building_textures[building_info.key]
    return null unless textures?.length && textures[0]?

    is_building_animated = textures.length == 1 || !@ui_state.render_building_animations
    sprite = if is_building_animated then @static_sprite(counter.building.static, textures[0]) else @animated_sprite(@animated_sprites, counter.building.animated, .2, textures)

    metadata = @building_manager.building_metadata.buildings[building_info.key]
    width = metadata.w * tile_width
    height = Math.ceil(textures[0].height * (width / textures[0].width))
    sprite.map_half_height = Math.round(.5 * metadata.h * tile_height)

    effect_sprites = []
    if metadata.effects? && @ui_state.render_building_effects
      for effect in metadata.effects
        effect_metadata = @effect_manager.effect_metadata.effects[effect.type]
        effect_textures = @effect_manager.effect_textures[effect.type]
        continue unless effect_metadata? && effect_textures?.length
        effect_sprite = @animated_sprite(@effect_sprites, counter.building.effect + effect_sprites.length, .1, effect_textures)
        effect_sprite.parent_sprite = sprite
        effect_sprites.push(new SpriteEffect(effect_textures[0].width * @game_state.game_scale, effect_textures[0].height * @game_state.game_scale, effect_sprite,
            Math.round(width * effect.x), Math.round(height * effect.y), Math.floor(effect_metadata.s_x * @game_state.game_scale), Math.floor(effect_metadata.s_y * @game_state.game_scale)))

    new SpriteBuilding(width, height, sprite, effect_sprites)

  hide_sprites: (counter) ->
    for index in [counter.building.static...@static_sprites.length]
      @static_sprites[index].visible = false
      @static_sprites[index].x = -1000
      @static_sprites[index].y = -1000
    for index in [counter.building.animated...@animated_sprites.length]
      @animated_sprites[index].stop()
      @animated_sprites[index].visible = false
      @animated_sprites[index].x = -1000
      @animated_sprites[index].y = -1000
    for index in [counter.building.effect...@effect_sprites.length]
      @effect_sprites[index].stop()
      @effect_sprites[index].visible = false
      @effect_sprites[index].x = -1000
      @effect_sprites[index].y = -1000
