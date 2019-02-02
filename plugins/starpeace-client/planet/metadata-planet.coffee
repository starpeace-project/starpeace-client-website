
import moment from 'moment'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class MetadataPlanet
  constructor: (@id) ->
    @as_of = moment()

  is_fresh: () -> TimeUtils.within_minutes(@as_of, 15)

  @from_json: (json) ->
    metadata = new MetadataPlanet(json.id)
    metadata.system_name = json.system_name
    metadata.name = json.name
    metadata.enabled = json.enabled == true || json.enabled == "true"
    metadata.planet_type = json.planet_type
    metadata.planet_width = json.planet_width
    metadata.planet_height = json.planet_height
    metadata.map_id = json.map_id
    metadata.population = json.population
    metadata.investment_value = json.investment_value
    metadata.tycoon_count = json.tycoon_count
    metadata.online_count = json.online_count
    metadata
