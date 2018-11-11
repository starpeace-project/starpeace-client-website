
import TileItemCache from '~/plugins/starpeace-client/renderer/item/tile-item-cache.coffee'
import LayerManager from '~/plugins/starpeace-client/renderer/layer/layer-manager.coffee'

PLANE_CHECK_SPEED = 5000

export default class Layers
  constructor: (@renderer, building_manager, effect_manager, @plane_manager, @game_state, @options, @ui_state) ->
    @needs_refresh = false

    @tile_item_cache = new TileItemCache(building_manager, effect_manager, @plane_manager, @game_state, @options, @ui_state)
    @layer_manager = new LayerManager(@game_state, @ui_state)

    @last_view_offset_x = 0
    @last_view_offset_y = 0

    @check_loop = setInterval(=>
      return unless @plane_manager.has_assets() && @game_state.initialized && @options.option('renderer.planes') && !@game_state.plane_sprite?
      @game_state.plane_sprite = @tile_item_cache.plane_sprite_info_for(@plane_manager.random_flight_plan(@renderer.viewport()))
    , PLANE_CHECK_SPEED)

    @refresh()

  destroy: () ->
    clearInterval(@check_loop) if @check_loop?
    @layer_manager.destroy()

  remove_layers: (stage) -> @layer_manager.remove_from_stage(stage)
  add_layers: (stage) -> @layer_manager.add_to_stage(stage)

  should_refresh: () -> @needs_refresh || (@last_view_offset_x != @game_state.view_offset_x || @last_view_offset_y != @game_state.view_offset_y) || @tile_item_cache.is_dirty || @tile_item_cache.should_clear_cache()
  mark_dirty: () -> @needs_refresh = true

  refresh_planes: () ->
    return unless @game_state.plane_sprite?
    if @game_state.plane_sprite.is_done || !@options.option('renderer.planes')
      # FIXME: TODO: probably need to clear plane better
      @game_state.plane_sprite = null
      return

    @game_state.plane_sprite.sprite = @layer_manager.plane_sprite_with(@game_state.plane_sprite.textures) unless @game_state.plane_sprite.sprite?
    @game_state.plane_sprite.render(@game_state.plane_sprite.sprite, @renderer.viewport())

  refresh: () ->
    @tile_item_cache.clear_cache() if @tile_item_cache.should_clear_cache()
    @tile_item_cache.reset_cache()

    viewport = @renderer.viewport()
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

    x = i_start
    while x < i_max
      j = j_start - n
      while j < (j_start + m)
        if j > 0 && j < @game_state.game_map.height && x > 0 && x < @game_state.game_map.width
          tile_item = @tile_item_cache.cache_item(x, j)
          @layer_manager.render_tile_item(render_state, tile_item, viewport.iso_to_canvas(x, j, view_center), viewport) if tile_item?

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
    @needs_refresh = false
    @last_view_offset_x = @game_state.view_offset_x
    @last_view_offset_y = @game_state.view_offset_y
