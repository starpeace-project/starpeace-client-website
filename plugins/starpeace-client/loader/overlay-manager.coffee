
import BuildingZone from '~/plugins/starpeace-client/map/building-zone.coffee'
import Overlay from '~/plugins/starpeace-client/map/overlay.coffee'

DUMMY_ZONE_CHUNK_DATA = {}
for type in ['ZONES', 'BEAUTY', 'HC_RESIDENTIAL', 'MC_RESIDENTIAL', 'LC_RESIDENTIAL', 'QOL',
    'CRIME', 'POLLUTION', 'BAP', 'FRESH_FOOD', 'PROCESSED_FOOD', 'CLOTHES', 'APPLIANCES',
    'CARS', 'RESTAURANTS', 'BARS', 'TOYS', 'DRUGS', 'MOVIES', 'GASOLINE', 'COMPUTERS',
    'FURNITURE', 'BOOKS', 'COMPACT_DISCS', 'FUNERAL_PARLORS']
  for chunk_y in [2...5]
    for chunk_x in [8...11]
      info = DUMMY_ZONE_CHUNK_DATA["#{type}x#{chunk_x}x#{chunk_y}"] = {
        chunk_x: chunk_x
        chunk_y: chunk_y
        width: 20
        height: 20
        data: []
      }

      if type == 'ZONES'
        info.data = "1111122222333334444411111222223333344444111112222233333444441111122222333334444411111222223333344444" +
            "5555566666777778888855555666667777788888555556666677777888885555566666777778888855555666667777788888" +
            "9999900000000000000099999000000000000000999990000000000000009999900000000000000099999000000000000000" +
            "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      else
        magnitude = 0.5 + 0.5 * Math.random()
        for y in [0...20]
          for x in [0...20]
            distance = Math.sqrt((10 - x) * (10 - x) + (10 - y) * (10 - y))
            info.data[y * 20 + x] = Math.round(255 * (1 - magnitude * (distance / 10))).toString(16).padStart(2, '0')


class OverlayManager
  constructor: (@client) ->
    @chunk_promises = {}

  load_chunk: (type, chunk_x, chunk_y, width, height) ->
    key = "#{type}x#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    console.debug "[STARPEACE] attempting to load overlay chunk for #{type} at #{chunk_x}x#{chunk_y}"
    @chunk_promises[key] = new Promise (done) =>
      data = new Array(width, height).fill(Overlay.TYPES.NONE)

      chunk = DUMMY_ZONE_CHUNK_DATA[key]
      if type == 'ZONES'
        data = BuildingZone.deserialize_chunk(chunk.width, chunk.height, chunk.data) if chunk?
      else if type == 'TOWNS'
        data = data
      else
        data = Overlay.deserialize_chunk(chunk.width, chunk.height, chunk.data) if chunk?

      setTimeout(=>
        delete @chunk_promises[key]
        done(data)
      , 500)

export default OverlayManager