
###
global PIXI
###

import SpriteLand from '~/plugins/starpeace-client/renderer/sprite/sprite-land.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_TILES = 25000

export default class LayerLand
  constructor: (@game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      tint: true
      uvs: true
      vertices: true
    })

    Logger.debug "configured map land layer for up to #{MAX_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.land = 0

  sprite_for_texture: (texture, counter, tile_width, tile_height) ->
    throw "maximum number of land particles reached" if counter.land >= MAX_TILES

    # texture = @game_state.game_map.ground_map.ground_texture_for(@game_state.current_season, y, x)
    if counter.land >= @sprites.length
      @sprites[counter.land] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[counter.land])
    else
      @sprites[counter.land].texture = texture

    new SpriteLand(tile_width, tile_height, @sprites[counter.land])

  blank_sprite_for: (counter, tile_width, tile_height) ->
    @sprite_for_texture(PIXI.utils.TextureCache["#{@game_state.current_season}.255.border.center.1"], counter, tile_width, tile_height)

  sprite_for: (land_info, counter, x, y, tile_width, tile_height) ->
    texture_id = _.values(land_info?.textures?['0deg']?[@game_state.current_season] || {})[0]
    texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length

    unless texture?
      Logger.debug("unable to find ground texture <#{texture_id}> for coord <#{x}>x<#{y}>, will fall back to default")
      texture = PIXI.utils.TextureCache["#{@game_state.current_season}.255.border.center.1"]

    @sprite_for_texture(texture, counter, tile_width, tile_height)


  hide_sprites: (counter) ->
    for index in [counter.land...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000
