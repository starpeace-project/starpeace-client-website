
export default class MetadataLand
  @DEFAULT_TILE_WIDTH: 64
  @DEFAULT_TILE_HEIGHT: 32

  constructor: (@id) ->

  set_ground_definitions: (definitions) ->
    @ground_definitions_by_color = {}
    @ground_definitions_by_color[ground.map_color] = ground for ground_key,ground of definitions

  set_tree_definitions: (definitions) ->
    @tree_definitions_by_zone = {}
    for tree_key,tree of definitions
      @tree_definitions_by_zone[tree.zone] ||= []
      @tree_definitions_by_zone[tree.zone].push tree

  has_ground_for_color: (color) -> @ground_definitions_by_color[color]?
  ground_for_color: (color) -> @ground_definitions_by_color[color]

  zones_with_trees: (zone) -> new Set(Object.keys(@tree_definitions_by_zone))
  random_tree_for_zone: (zone) ->
    trees = @tree_definitions_by_zone[zone] || []
    return null unless trees.length
    trees[Math.floor(Math.random() * trees.length)]

  @from_json: (json) ->
    metadata = new MetadataLand(json.id)
    metadata.planet_type = json.planet_type
    metadata.set_ground_definitions(json.ground_definitions)
    metadata.set_tree_definitions(json.tree_definitions)
    metadata

# ground_definitions: {ground.000.grass: {…}, ground.001.grass: {…}, ground.002.grass: {…}, ground.003.grass: {…}, ground.064.midgrass: {…}, …}
# planet_type: "earth"
# tree_definitions
#
#     id: (...)
# textures: (...)
# zone: (...)
