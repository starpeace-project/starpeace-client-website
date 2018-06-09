

window.starpeace ||= {}
window.starpeace.metadata ||= {}
window.starpeace.metadata.PlanetTypeManifest = class PlanetTypeManifest
  @DEFAULT_TILE_WIDTH: 64
  @DEFAULT_TILE_HEIGHT: 32

  constructor: (@planet_type, @ground_definitions_by_id, @tree_definitions_by_id) ->
    @ground_definitions_by_color = {}
    @ground_definitions_by_color[ground.map_color] = ground for ground_key,ground of @ground_definitions_by_id

    @tree_definitions_by_zone = {}
    for tree_key,tree of @tree_definitions_by_id
      @tree_definitions_by_zone[tree.zone] ||= []
      @tree_definitions_by_zone[tree.zone].push tree


  has_ground_for_color: (color) -> @ground_definitions_by_color[color]?
  ground_for_color: (color) -> @ground_definitions_by_color[color]

  zones_with_trees: (zone) -> new Set(Object.keys(@tree_definitions_by_zone))
  random_tree_for_zone: (zone) ->
    trees = @tree_definitions_by_zone[zone] || []
    return null unless trees.length
    trees[Math.floor(Math.random() * trees.length)]
