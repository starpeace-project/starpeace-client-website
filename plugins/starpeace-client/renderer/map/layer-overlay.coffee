
###
global PIXI
###

MAX_TILES = 25000

class LayerOverlay
  constructor: (@renderer, @game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_TILES, {
      tint: true
    })

    console.debug "[STARPEACE] configured map overlay layer for up to #{MAX_TILES} sprites"


  sprite_for: (sprite_index, x, y) ->
    throw "maximum number of overlay particles reached" if sprite_index >= MAX_TILES

    texture = PIXI.utils.TextureCache['overlay']
    if sprite_index >= @sprites.length
      @sprites[sprite_index] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[sprite_index]) if @container?

    @sprites[sprite_index]


  hide_sprites: (from_index) ->
    for index in [from_index...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000

export default LayerOverlay
