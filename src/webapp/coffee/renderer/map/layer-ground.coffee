
MAX_GROUND_TILES = 25000

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.map ||= {}
window.starpeace.renderer.map.LayerGround = class LayerGround

  constructor: (@renderer, @game_state) ->
    @sprites = []
    @container = new PIXI.particles.ParticleContainer(MAX_GROUND_TILES, {
      uvs: true
    })

    console.debug "[STARPEACE] configured map ground layer for up to #{MAX_GROUND_TILES} sprites"


  sprite_for: (sprite_index, x, y) ->
    throw "maximum number of ground particles reached" if sprite_index >= MAX_GROUND_TILES

    texture = @game_state.game_map.ground_texture_for(@game_state.current_season, y, x)
    if sprite_index >= @sprites.length
      @sprites[sprite_index] = new PIXI.Sprite(texture)
      @container.addChild(@sprites[sprite_index]) if @container?
    else
      @sprites[sprite_index].texture = texture

    @sprites[sprite_index]


  hide_sprites: (from_index) ->
    for index in [from_index...@sprites.length]
      @sprites[index].visible = false
      @sprites[index].x = -1000
      @sprites[index].y = -1000

