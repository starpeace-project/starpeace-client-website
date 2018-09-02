
import Logger from '~/plugins/starpeace-client/logger.coffee'

TREE_TYPE_PERCENTAGE = {}
TREE_TYPE_PERCENTAGE.grass = .3
TREE_TYPE_PERCENTAGE.midgrass = .2
TREE_TYPE_PERCENTAGE.dryground = .1

export default class LandMap
  constructor: (@width, @height, @ground_map_tiles, @tree_map_tiles) ->

  tree_at: (x, y) -> @tree_map_tiles[(@height - x) * @width + (@width - y)]
  ground_at: (x, y) -> @ground_map_tiles[(@height - x) * @width + (@width - y)]

  is_coast_at: (x, y) -> @ground_at(x, y)?.is_coast
  is_coast_around: (x, y) ->
    @ground_at(x, y)?.is_coast || @ground_at(x - 1, y)?.is_coast || @ground_at(x + 1, y)?.is_coast || @ground_at(x, y - 1)?.is_coast
  is_water_at: (x, y) -> @ground_at(x, y)?.zone == 'water'

  @from_pixel_data: (manifest, map_width, map_height, map_pixels) ->
    zones_with_trees = manifest.zones_with_trees()
    ground_tiles = new Array(map_height * map_width)
    tree_tiles = new Array(map_height * map_width)
    for y in [0...map_height]
      for x in [0...map_width]
        index = (y * map_width + x) * 4
        color = ((map_pixels[index + 2] << 16) & 0xFF0000) | ((map_pixels[index + 1] << 8) & 0x00FF00) | ((map_pixels[index + 0] << 0) & 0x0000FF)

        map_index = y * map_width + x
        ground_tiles[map_index] = manifest.ground_for_color(color) if manifest.has_ground_for_color(color)
        tree_tiles[map_index] = manifest.random_tree_for_zone(ground_tiles[map_index].zone) if zones_with_trees.has(ground_tiles[map_index]?.zone) && Math.random() < (TREE_TYPE_PERCENTAGE[ground_tiles[map_index]?.zone] || 0.2)


    new LandMap(map_width, map_height, ground_tiles, tree_tiles)
