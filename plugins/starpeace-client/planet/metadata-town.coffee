
import moment from 'moment'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class MetadataTown
  constructor: (@id) ->
    @as_of = moment()

  is_fresh: () -> TimeUtils.within_minutes(@as_of, 15)

  @from_json: (json) ->
    metadata = new MetadataTown(json.id)
    metadata.name = json.name
    metadata.seal_id = json.seal_id
    metadata.building_id = json.building_id
    metadata.map_x = json.map_x
    metadata.map_y = json.map_y
    metadata
