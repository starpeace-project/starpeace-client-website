

window.starpeace ||= {}
window.starpeace.loader ||= {}
window.starpeace.loader.BuildingManager = class BuildingManager

  constructor: (@client) ->
    @chunk_promises = {}

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

