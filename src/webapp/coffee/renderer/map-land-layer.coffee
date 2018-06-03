

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.MapLandLayer = class MapLandLayer

  constructor: (@renderer, @land_manifest, @game_state) ->
    @needs_refresh = false

    throw "attempting to create MapLandLayer without map" unless @game_state.game_map?

    @tile_sprites = []
    @refresh()
    console.debug "[STARPEACE] created #{@tile_sprites.length} sprites for map land layere"

    @max_sprite_count = Math.round(@tile_sprites.length * 1.2)
    console.debug "[STARPEACE] configuring map land layer for up to #{@max_sprite_count} tiles"
    @container = new PIXI.particles.ParticleContainer(@max_sprite_count, {
      scale: true
      position: true
      uvs: true
    })

    @container.addChild(sprite) for sprite in @tile_sprites

  sprite: (index, land_texture) ->
    throw "maximum number of tile particles reached" if @max_sprite_count? && index >= @max_sprite_count
    if index >= @tile_sprites.length
      @tile_sprites[index] = new PIXI.Sprite(land_texture)
      @container.addChild(@tile_sprites[index]) if @container?
    else
      @tile_sprites[index].texture = land_texture
    @tile_sprites[index]

  hide_sprites: (from_index) ->
    @tile_sprites[index].visible = false for index in [from_index...@tile_sprites.length]

  refresh: () ->
    @needs_refresh = false

    map_width = @game_state.game_map.width
    map_height = @game_state.game_map.height

    canvas_width = Math.round(@renderer.renderer_width || 0)
    canvas_height = Math.round(@renderer.renderer_height || 0)

    tile_width = starpeace.metadata.LandManifest.DEFAULT_TILE_WIDTH
    tile_height = starpeace.metadata.LandManifest.DEFAULT_TILE_HEIGHT
    half_tile_width = Math.round(tile_width / 2)
    half_tile_height = Math.round(tile_height / 2)

    width_in_tiles = Math.ceil(canvas_width / tile_width) + 4
    fixed_y = half_tile_height * width_in_tiles
    fixed_bottom_y = tile_height * map_width - canvas_height - fixed_y

    initial_y = @game_state.view_offset_y
    view_y = @game_state.view_offset_y #Math.round(Math.min(fixed_bottom_y, Math.max(fixed_y, initial_y)))

    C = 2 * tile_height
    initial_x = @game_state.view_offset_x

    min_x = Math.round(-4.0 / 2.0 * view_y + 4.0 / 2.0 * C)
    max_x = Math.round(4.0 / 2.0 * view_y - 4.0 / 2.0 * C) - canvas_width
    view_x = @game_state.view_offset_x #Math.round(Math.min(max_x, Math.max(min_x, initial_x)))

#     console.log "(#{min_x} to #{max_x}) #{view_x}  #{view_y}"

    i_start = starpeace.renderer.Utils.iso_to_i(half_tile_height, half_tile_width, view_x, view_y)
    j_start = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x, view_y)
    i_max = starpeace.renderer.Utils.iso_to_i(half_tile_height, half_tile_width, view_x + canvas_width, view_y + canvas_height) + 2
    j_max = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x, view_y + canvas_height) + 2
    j_min = starpeace.renderer.Utils.iso_to_j(half_tile_height, half_tile_width, view_x + canvas_width, view_y)

    n_bump = false
    m_bump = false
    n = 0
    n_buffer = 4
    m = 1
    m_buffer = 0

    sprite_index = 0
    skip = 0
    x = i_start
    while x < i_max
      j = j_start - n
      while j < (j_start + m)

        canvas_x = (x - j) * half_tile_width - view_x - 1 - tile_width
        canvas_y = (x + j) * half_tile_height - view_y - tile_height

        if canvas_x >= -tile_width && (canvas_x < canvas_width + tile_width) && canvas_y >= -tile_height && (canvas_y < canvas_height + tile_height)
          land_texture = @game_state.game_map.texture_for(x, j)
          land_sprite = @sprite(sprite_index, land_texture)
          land_sprite.visible = true
          land_sprite.x = canvas_x
          land_sprite.y = canvas_y
          sprite_index += 1
        else
#           console.log "skip at #{x} #{j} @ #{canvas_x} #{canvas_y}"
          skip += 1

        j += 1

      unless n_bump
        n += 1
        n_bump = ((j_start - n) == j_min)
        n += 1 if n_bump
      else
        if n_buffer > 0
          n_buffer -= 1
        else
          n -= 1

      unless m_bump
        m += 1
        m_bump = ((j_start + m) == j_max)
      else
        if m_buffer > 0
          m_buffer -= 1
        else
          m -= 1

      x += 1

    @hide_sprites(sprite_index)

