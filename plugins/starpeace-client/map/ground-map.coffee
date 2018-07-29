
import Logger from '~/plugins/starpeace-client/logger.coffee'

TREE_TYPE_PERCENTAGE = {}
TREE_TYPE_PERCENTAGE.grass = .3
TREE_TYPE_PERCENTAGE.midgrass = .2
TREE_TYPE_PERCENTAGE.dryground = .1

export default class GroundMap
  constructor: (@width, @height, @ground_map_tiles, @tree_map_tiles) ->

  tree_at: (x, y) -> @tree_map_tiles[(@height - x) * @width + (@width - y)]
  ground_at: (x, y) -> @ground_map_tiles[(@height - x) * @width + (@width - y)]

  is_water_at: (x, y) ->
    @ground_at(x, y).zone == 'water'
  is_water_around: (x, y) ->
    @ground_at(x, y).zone == 'water' || @ground_at(x - 1, y).zone == 'water' || @ground_at(x + 1, y).zone == 'water' ||
        @ground_at(x, y - 1).zone == 'water' || @ground_at(x, y + 1).zone == 'water' || @ground_at(x - 1, y - 1).zone == 'water' ||
        @ground_at(x - 1, y + 1).zone == 'water' || @ground_at(x + 1, y - 1).zone == 'water' || @ground_at(x + 1, y + 1).zone == 'water'

  @pixels_for_image: (image) ->
    canvas = document.createElement('canvas')
    canvas.width = image.width
    canvas.height = image.height
    canvas.getContext('2d').drawImage(image, 0, 0, image.width, image.height)
    canvas.getContext('2d').getImageData(0, 0, image.width, image.height).data

  @from_texture: (manifest, texture) ->
    map_width = texture.texture.width
    map_height = texture.texture.height

    zones_with_trees = manifest.zones_with_trees()
    pixels = GroundMap.pixels_for_image(texture.data)
    ground_tiles = new Array(map_height * map_width)
    tree_tiles = new Array(map_height * map_width)
    for y in [0...map_height]
      for x in [0...map_width]
        index = (y * map_width + x) * 4
        color = ((pixels[index + 2] << 16) & 0xFF0000) | ((pixels[index + 1] << 8) & 0x00FF00) | ((pixels[index + 0] << 0) & 0x0000FF)

        map_index = y * map_width + x
        ground_tiles[map_index] = manifest.ground_for_color(color) if manifest.has_ground_for_color(color)
        tree_tiles[map_index] = manifest.random_tree_for_zone(ground_tiles[map_index].zone) if zones_with_trees.has(ground_tiles[map_index]?.zone) && Math.random() < (TREE_TYPE_PERCENTAGE[ground_tiles[map_index]?.zone] || 0.2)


    new GroundMap(map_width, map_height, ground_tiles, tree_tiles)
