
import _ from 'lodash'
import moment from 'moment'

import MetadataTown from '~/plugins/starpeace-client/planet/metadata-town.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class DetailsPlanet
  constructor: (@id) ->
    @as_of = moment()

  is_fresh: () -> TimeUtils.within_minutes(@as_of, 15)

  @from_json: (json) ->
    metadata = new DetailsPlanet(json.id)
    metadata.system_id = json.system_id
    metadata.name = json.name
    metadata.towns_metadata = _.map(json.towns, MetadataTown.from_json)
    metadata
