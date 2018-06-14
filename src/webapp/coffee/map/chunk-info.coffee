
window.starpeace ||= {}
window.starpeace.map ||= {}
window.starpeace.map.ChunkInfo = class ChunkInfo

  constructor: (@x, @y, @width, @height, @max_age_mins) ->
    @last_updated = moment()

  is_current: () ->
    @last_updated.add(@max_age_mins, 'minutes').isAfter(moment())

  update: () ->
    @last_updated = moment()
