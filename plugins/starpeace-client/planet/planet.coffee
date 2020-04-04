
import moment from 'moment'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class Planet
  constructor: (@id) ->
    @as_of = moment()

  is_fresh: () -> TimeUtils.within_minutes(@as_of, 15)

  @from_json: (json) ->
    metadata = new Planet(json.id)
    metadata.name = json.name
    metadata.enabled = json.enabled == true || json.enabled == "true"
    metadata.planet_type = json.planetType
    metadata.planet_width = json.planetWidth
    metadata.planet_height = json.planetHeight
    metadata.map_id = json.mapId
    metadata.population = json.population
    metadata.investment_value = json.investmentValue
    metadata.corporation_count = json.corporationCount
    metadata.online_count = json.onlineCount
    metadata
