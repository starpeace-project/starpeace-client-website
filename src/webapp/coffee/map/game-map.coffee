

window.starpeace ||= {}
window.starpeace.map ||= {}
window.starpeace.map.GameMap = class GameMap

  constructor: (@width, @height, @map_land_tiles) ->
    

  @pixels_for_image: (image) ->
    canvas = document.createElement('canvas')
    canvas.width = image.width
    canvas.height = image.height
    canvas.getContext('2d').drawImage(image, 0, 0, image.width, image.height)
    canvas.getContext('2d').getImageData(0, 0, image.width, image.height).data

  @from_texture: (land_metadata_by_color, texture) ->
    map_width = texture.texture.width
    map_height = texture.texture.height

    pixels = GameMap.pixels_for_image(texture.data)
    map_tiles = new Array(map_height * map_width)
    for y in [0...map_height]
      for x in [0...map_width]
        index = (y * map_width + x) * 4
        color = ((pixels[index + 2] << 16) & 0xFF0000) | ((pixels[index + 1] << 8) & 0x00FF00) | ((pixels[index + 0] << 0) & 0x0000FF)
        map_tiles[y * map_width + x] = land_metadata_by_color[color] if land_metadata_by_color[color]?

    new GameMap(map_width, map_height, map_tiles)
