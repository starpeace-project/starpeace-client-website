
DUMMY_ZONE_CHUNK_DATA = {}
DUMMY_ZONE_CHUNK_DATA["9x3"] = {
  chunk_x: 9
  chunk_y: 3
  width: 20
  height: 20
  data: "1111122222333334444411111222223333344444111112222233333444441111122222333334444411111222223333344444" +
    "5555566666777778888855555666667777788888555556666677777888885555566666777778888855555666667777788888" +
    "9999900000000000000099999000000000000000999990000000000000009999900000000000000099999000000000000000" +
    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
}

window.starpeace ||= {}
window.starpeace.loader ||= {}
window.starpeace.loader.BuildingManager = class BuildingManager

  constructor: (@client) ->
    @chunk_promises = {}
    @zone_chunk_promises = {}

  load_building_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    console.debug "[STARPEACE] attempting to load building chunk #{chunk_x}x#{chunk_y}"

    @chunk_promises[key] = setTimeout(=>
      map_x = chunk_x * width
      map_y = chunk_y * height

      @client.game_state.game_map.building_map.load_chunk(chunk_x, chunk_y, [])
      delete @chunk_promises[key]
    , 500)


  load_zone_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @zone_chunk_promises[key]?

    console.debug "[STARPEACE] attempting to load zone chunk #{chunk_x}x#{chunk_y}"

    data = new Array(width, height).fill(starpeace.map.CityZone.TYPES.NONE)

    chunk = DUMMY_ZONE_CHUNK_DATA[key]
    data = starpeace.map.CityZone.deserialize_chunk(chunk.width, chunk.height, chunk.data) if chunk?

    @zone_chunk_promises[key] = setTimeout(=>
      @client.game_state.game_map.building_map.load_zone_chunk(chunk_x, chunk_y, data)
      delete @zone_chunk_promises[key]
    , 500)

