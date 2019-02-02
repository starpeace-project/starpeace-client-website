
import TileItemCache from '~/plugins/starpeace-client/renderer/item/tile-item-cache.coffee'
import LayerManager from '~/plugins/starpeace-client/renderer/layer/layer-manager.coffee'

PLANE_CHECK_SPEED = 5000
PLANE_COUNT = 6

export default class Layers
  constructor: (@renderer, building_manager, effect_manager, @plane_manager, @client_state, @options) ->
    @tile_item_cache = new TileItemCache(building_manager, effect_manager, @plane_manager, @client_state, @options)
    @layer_manager = new LayerManager(@client_state)

    @last_view_offset_x = 0
    @last_view_offset_y = 0
    @last_construction_building_id = null
    @last_construction_building_x = 0
    @last_construction_building_y = 0

    @check_loop = setInterval(=>
      return unless @client_state.initialized && @options.option('renderer.planes')

      while @client_state.plane_sprites.length < PLANE_COUNT
        flight_plan = @plane_manager.random_flight_plan(@client_state.camera)
        sprite = @tile_item_cache.plane_sprite_info_for(flight_plan)
        return unless sprite?
        @client_state.plane_sprites[@client_state.plane_sprites.length] = sprite # need to be careful to avoid Vue state wrapper

    , PLANE_CHECK_SPEED)

    @refresh()

  destroy: () ->
    clearInterval(@check_loop) if @check_loop?
    @layer_manager.destroy()

  remove_layers: (stage) -> @layer_manager.remove_from_stage(stage)
  add_layers: (stage) -> @layer_manager.add_to_stage(stage)

  should_refresh: () ->
    @last_view_offset_x != @client_state.camera.view_offset_x || @last_view_offset_y != @client_state.camera.view_offset_y ||
      @last_construction_building_id != @client_state.interface.construction_building_id || @last_construction_building_x != @client_state.interface.construction_building_map_x ||
      @last_construction_building_y != @client_state.interface.construction_building_map_y || @tile_item_cache.is_dirty || @tile_item_cache.should_clear_cache()

  refresh_planes: () ->
    return unless @client_state.initialized && @client_state.renderer_initialized && @client_state.plane_sprites.length
    if !@options.option('renderer.planes')
      @client_state.plane_sprites = []
      @layer_manager.clear_cache_plane_sprites({})
      return

    render_state = {}
    to_remove = []
    for sprite,index in @client_state.plane_sprites
      if sprite.is_done
        to_remove.push index
      else
        sprite.sprite = @layer_manager.plane_sprite_with(render_state, sprite.textures)
        sprite.render(sprite.sprite, @client_state.camera)

    @layer_manager.clear_cache_plane_sprites(render_state)
    @client_state.plane_sprites.splice(index, 1) for index in to_remove.reverse()

  refresh: () ->
    return unless @client_state.initialized && @client_state.renderer_initialized

    @tile_item_cache.clear_cache() if @tile_item_cache.should_clear_cache()
    @tile_item_cache.reset_cache()

    viewport = @client_state.camera
    view_center = viewport.top_left()
    iso_start = viewport.map_to_iso(view_center.x, view_center.y)
    iso_max_i = viewport.map_to_iso(view_center.x + viewport.canvas_width, view_center.y + viewport.canvas_height)
    iso_max_j = viewport.map_to_iso(view_center.x, view_center.y + viewport.canvas_height)
    iso_min_j = viewport.map_to_iso(view_center.x + viewport.canvas_width, view_center.y)

    i_start = iso_start.i - 8
    j_start = iso_start.j
    i_max = iso_max_i.i + 24
    j_max = iso_max_j.j + 30
    j_min = iso_min_j.j - 6

    n_bump = false
    m_bump = false
    n = 0
    n_buffer = 4
    m = 10
    m_buffer = 6

    render_state = {}

    construction_x = if @client_state.interface.construction_building_id? then @client_state.interface.construction_building_map_x else -1
    construction_y = if @client_state.interface.construction_building_id? then @client_state.interface.construction_building_map_y else -1

    x = i_start
    while x < i_max
      j = j_start - n
      while j < (j_start + m)
        if j > 0 && j < @client_state.planet.game_map.height && x > 0 && x < @client_state.planet.game_map.width
          tile_item = @tile_item_cache.cache_item(x, j)
          construction_item = if @client_state.interface.construction_building_id? && construction_x == x && construction_y == j then @tile_item_cache.building_construction_sprite_info_for(@client_state.interface.construction_building_id, @client_state.can_construct_building()) else null
          within_construction = construction_x >= 0 && x > construction_x - @client_state.interface.construction_building_width && x <= construction_x &&
              construction_y >= 0 && j > construction_y - @client_state.interface.construction_building_height && j <= construction_y
          @layer_manager.render_tile_item(render_state, tile_item, construction_item, within_construction, viewport.iso_to_canvas(x, j, view_center), viewport) if tile_item?

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

    @layer_manager.clear_cache_sprites(render_state)
    @last_view_offset_x = @client_state.camera.view_offset_x
    @last_view_offset_y = @client_state.camera.view_offset_y
    @last_construction_building_id = @client_state.interface.construction_building_id
    @last_construction_building_x = @client_state.interface.construction_building_map_x
    @last_construction_building_y = @client_state.interface.construction_building_map_y
