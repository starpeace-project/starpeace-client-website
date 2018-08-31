
import Overlay from '~/plugins/starpeace-client/map/types/overlay.coffee'

DEFAULT_MINI_MAP_WIDTH = 300
DEFAULT_MINI_MAP_HEIGHT = 200

export default class UIState
  constructor: () ->
    @event_ticker_message = ''

    @saved_show_header = @show_header = true
    @saved_show_fps = @show_fps = true
    @saved_show_mini_map = @show_mini_map = true
    @saved_game_music = @game_music = false

    @mini_map_width = DEFAULT_MINI_MAP_WIDTH
    @mini_map_height = DEFAULT_MINI_MAP_HEIGHT

    @show_overlay = false
    @current_overlay = Overlay.TYPES.TOWNS
    @show_losing_facilities = false

    @show_zones = false

    @render_trees = true
    @render_buildings = true
    @render_building_animations = true
    @render_building_effects = true
    @render_planes = true

    @load_state()

  load_state: () ->
    show_header = localStorage.getItem('options.show_header') || 'true'
    show_fps = localStorage.getItem('options.show_fps') || 'true'
    show_mini_map = localStorage.getItem('options.show_mini_map') || 'true'
    game_music = localStorage.getItem('options.game_music') || 'true'

    mini_map_width = localStorage.getItem('mini_map.width')
    mini_map_height = localStorage.getItem('mini_map.height')

    render_trees = localStorage.getItem('options.render_trees')
    render_buildings = localStorage.getItem('options.render_buildings')
    render_building_animations = localStorage.getItem('options.render_building_animations')
    render_building_effects = localStorage.getItem('options.render_building_effects')
    render_planes = localStorage.getItem('options.render_planes')

    @saved_show_header = @show_header = show_header == 'true'
    @saved_show_fps = @show_fps = show_fps == 'true'
    @saved_show_mini_map = @show_mini_map = show_mini_map == 'true'
    @saved_game_music = @game_music = game_music == 'true'

    @mini_map_x = parseInt(mini_map_width) if mini_map_x?.length
    @mini_map_y = parseInt(mini_map_height) if mini_map_y?.length
    @mini_map_width = parseInt(mini_map_width) if mini_map_width?.length
    @mini_map_height = parseInt(mini_map_height) if mini_map_height?.length

    @saved_render_trees = @render_trees = !render_trees? || render_trees == 'true'
    @saved_render_buildings = @render_buildings = !render_buildings? || render_buildings == 'true'
    @saved_render_building_animations = @render_building_animations = !render_building_animations? || render_building_animations == 'true'
    @saved_render_building_effects = @render_building_effects = !render_building_effects? || render_building_effects == 'true'
    @saved_render_planes = @render_planes = !render_planes? || render_planes == 'true'

  reset_state: () ->
    localStorage.removeItem('options.show_header')
    localStorage.removeItem('options.show_fps')
    localStorage.removeItem('options.show_mini_map')
    localStorage.removeItem('options.game_music')

    localStorage.removeItem('mini_map.width')
    localStorage.removeItem('mini_map.height')

    localStorage.removeItem('options.render_trees')
    localStorage.removeItem('options.render_buildings')
    localStorage.removeItem('options.render_building_animations')
    localStorage.removeItem('options.render_building_effects')
    localStorage.removeItem('options.render_planes')

    @show_header = true
    @show_fps = true
    @game_music = false

    @mini_map_width = DEFAULT_MINI_MAP_WIDTH
    @mini_map_height = DEFAULT_MINI_MAP_HEIGHT

    @render_trees = true
    @render_buildings = true
    @render_building_animations = true
    @render_building_effects = true
    @render_planes = true

  save_state: () ->
    localStorage.setItem('options.show_header', @show_header.toString())
    localStorage.setItem('options.show_fps', @show_fps.toString())
    localStorage.setItem('options.show_mini_map', @show_mini_map.toString())
    localStorage.setItem('options.game_music', @game_music.toString())

    localStorage.setItem('options.render_trees', @render_trees.toString())
    localStorage.setItem('options.render_buildings', @render_buildings.toString())
    localStorage.setItem('options.render_building_animations', @render_building_animations.toString())
    localStorage.setItem('options.render_building_effects', @render_building_effects.toString())
    localStorage.setItem('options.render_planes', @render_planes.toString())

    @saved_show_header = @show_header
    @saved_show_fps = @show_fps
    @saved_show_mini_map = @show_mini_map
    @saved_game_music = @game_music

    @saved_render_trees = @render_trees
    @saved_render_buildings = @render_buildings
    @saved_render_building_animations = @render_building_animations
    @saved_render_building_effects = @render_building_effects
    @saved_render_planes = @render_planes

  toggle_overlay: () ->
    if @show_overlay
      @show_overlay = false
    else
      @show_zones = false
      @show_overlay = true

  toggle_zones: () ->
    if @show_zones
      @show_zones = false
    else
      @show_overlay = false
      @show_zones = true

  update_mini_map: (width, height) ->
    @mini_map_width = width
    @mini_map_height = height

    localStorage.setItem('mini_map.height', @mini_map_height.toString())
    localStorage.setItem('mini_map.width', @mini_map_width.toString())
