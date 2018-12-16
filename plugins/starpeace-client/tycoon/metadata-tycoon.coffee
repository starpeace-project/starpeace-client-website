
import moment from 'moment'

import MetadataCorporation from '~/plugins/starpeace-client/industry/metadata-corporation.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class MetadataTycoon
  constructor: (@id) ->
    @as_of = moment()

  is_fresh: () -> TimeUtils.within_minutes(@as_of, 15)

  @from_json: (json) ->
    metadata = new MetadataTycoon(json.id)
    metadata.name = json.name
    metadata.corporations_metadata = _.map(json.corporations, (corp_json) -> MetadataCorporation.from_json(json.id, corp_json))
    metadata
