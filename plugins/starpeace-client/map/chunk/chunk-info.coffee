
import moment from 'moment'

class ChunkInfo
  constructor: (@chunk_x, @chunk_y, @width, @height, @max_age_mins) ->
    @last_updated = moment()

  x_offset: () -> @chunk_x * @width
  y_offset: () -> @chunk_y * @height

  is_current: () ->
    @last_updated.add(@max_age_mins, 'minutes').isAfter(moment())

  update: () ->
    @last_updated = moment()

export default ChunkInfo
