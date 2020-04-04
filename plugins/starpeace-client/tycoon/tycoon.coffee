
import moment from 'moment'

import Corporation from '~/plugins/starpeace-client/industry/corporation.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class Tycoon
  constructor: (@id) ->
    @as_of = moment()

  is_fresh: () -> TimeUtils.within_minutes(@as_of, 15)

  @from_json: (json) ->
    metadata = new Tycoon(json.id)
    metadata.name = json.name
    metadata.corporations = _.map(json.corporations, (corp_json) -> Corporation.from_json(corp_json))
    metadata
