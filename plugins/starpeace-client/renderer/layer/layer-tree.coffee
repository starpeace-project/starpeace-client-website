
###
global PIXI
###

import SpriteTree from '~/plugins/starpeace-client/renderer/sprite/sprite-tree.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_TILES = 10000

export default class LayerTree
  constructor: (@game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      tint: true
      uvs: true
      vertices: true
    })

    Logger.debug "configured map tree layer for up to #{MAX_TILES} sprites"

  destroy: () ->
    @container.destroy({
      children: true
      textures: false
    })

  reset_counter: (counter) ->
    counter.tree = 0

  sprite_for: (tree_info, counter, x, y, tile_width, tile_height) ->
    throw "maximum number of tree particles reached" if counter.tree >= MAX_TILES

    texture_id = tree_info?.textures?[@game_state.current_season]
    texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length
    Logger.debug("unable to find tree texture <#{texture_id}> for coord <#{x}>x<#{y}>") unless texture?
    return null unless texture?

    if counter.tree >= @sprites.length
      @sprites[counter.tree] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[counter.tree])
    else
      @sprites[counter.tree].texture = texture

    new SpriteTree(tile_width, Math.ceil(texture.height * (tile_width / texture.width)), @sprites[counter.tree])

  hide_sprites: (counter) ->
    for index in [counter.tree...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000