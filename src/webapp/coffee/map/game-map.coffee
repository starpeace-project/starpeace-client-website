

window.starpeace ||= {}
window.starpeace.map ||= {}
window.starpeace.map.GameMap = class GameMap

  constructor: (@width, @height, @ground_map_tiles, @tree_map_tiles) ->

  index_at: (x, y) -> (@height - y) * @width + (@width - x)

  has_tree_at: (x, y) -> @tree_map_tiles[@index_at(x, y)]?
  tree_at: (x, y) -> @tree_map_tiles[@index_at(x, y)]

  has_ground_at: (x, y) -> @ground_map_tiles[@index_at(x, y)]?
  ground_at: (x, y) -> @ground_map_tiles[@index_at(x, y)]

  tree_texture_for: (x, y) ->
    texture = null
    unless x < 0 || x > @width || y < 0 || y > @height
      tree_tile = @tree_at(x, y)
      texture_id = tree_tile?.textures?.fall
      texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length
      console.debug "[STARPEACE] unable to find tree texture <#{texture_id}> for coord <#{x}>x<#{y}>" unless texture?
    texture

  ground_texture_for: (x, y) ->
    texture = PIXI.utils.TextureCache['fall.255.border.center.1']
    unless x < 0 || x > @width || y < 0 || y > @height
      tile = @ground_at(x, y)
      texture_id = _.values(tile?.textures?['0deg']?.fall)[0]
      texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length
      console.debug "[STARPEACE] unable to find ground texture <#{texture_id}> for coord <#{x}>x<#{y}>, will fall back to default" unless texture?
    texture


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
    pixels = GameMap.pixels_for_image(texture.data)
    ground_tiles = new Array(map_height * map_width)
    tree_tiles = new Array(map_height * map_width)
    for y in [0...map_height]
      for x in [0...map_width]
        index = (y * map_width + x) * 4
        color = ((pixels[index + 2] << 16) & 0xFF0000) | ((pixels[index + 1] << 8) & 0x00FF00) | ((pixels[index + 0] << 0) & 0x0000FF)

        map_index = y * map_width + x
        ground_tiles[map_index] = manifest.ground_for_color(color) if manifest.has_ground_for_color(color)
        tree_tiles[map_index] = manifest.random_tree_for_zone(ground_tiles[map_index].zone) if zones_with_trees.has(ground_tiles[map_index]?.zone) && Math.random() < 0.2

        true

    new GameMap(map_width, map_height, ground_tiles, tree_tiles)
