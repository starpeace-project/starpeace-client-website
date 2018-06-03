

window.starpeace ||= {}
window.starpeace.map ||= {}
window.starpeace.map.GameMap = class GameMap

  constructor: (@width, @height, @map_land_tiles) ->


  tile_for: (x, y) ->
    @map_land_tiles[y * @width + x]

  texture_for: (x, y) ->
    texture = PIXI.utils.TextureCache['fall.255.border.center.1']
    unless x < 0 || x > @width || y < 0 || y > @height
      tile = @tile_for(@width - x, @height - y)
      texture_id = _.values(tile?.textures?['0deg']?.fall)[0]
      texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length
      console.debug "[STARPEACE] unable to find land texture <#{texture_id}> for coord <#{x}>x<#{y}>, will fall back to default" unless texture?
    texture


  @pixels_for_image: (image) ->
    canvas = document.createElement('canvas')
    canvas.width = image.width
    canvas.height = image.height
    canvas.getContext('2d').drawImage(image, 0, 0, image.width, image.height)
    canvas.getContext('2d').getImageData(0, 0, image.width, image.height).data

  @from_texture: (land_manifest, texture) ->
    map_width = texture.texture.width
    map_height = texture.texture.height

    pixels = GameMap.pixels_for_image(texture.data)
    map_tiles = new Array(map_height * map_width)
    for y in [0...map_height]
      for x in [0...map_width]
        index = (y * map_width + x) * 4
        color = ((pixels[index + 2] << 16) & 0xFF0000) | ((pixels[index + 1] << 8) & 0x00FF00) | ((pixels[index + 0] << 0) & 0x0000FF)
        map_tiles[y * map_width + x] = land_manifest.definitions_by_color[color] if land_manifest.definitions_by_color[color]?

    new GameMap(map_width, map_height, map_tiles)
