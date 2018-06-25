
class BuildingManager
  constructor: (@client) ->
    @chunk_promises = {}

  load_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    console.debug "[STARPEACE] attempting to load building chunk at #{chunk_x}x#{chunk_y}"
    @chunk_promises[key] = new Promise (done) =>
      setTimeout(=>
        delete @chunk_promises[key]
        done([])
      , 500)

export default BuildingManager
