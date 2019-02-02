
import _ from 'lodash'
import moment from 'moment'

import MetadataPlanet from '~/plugins/starpeace-client/planet/metadata-planet.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class MetadataGalaxy
  constructor: (@id) ->
    @as_of = new Date()

    @planets_metadata = []

  Object.defineProperties @prototype,
    planet_count:
      get: -> @planets_metadata.length
    online_count:
      get: -> _.sumBy(@planets_metadata, 'online_count')

  @from_json: (json) ->
    metadata = new MetadataGalaxy(json.id)
    metadata.name = json.name
    metadata.visitor_enabled = json.visitor_enabled || false
    metadata.tycoon_enabled = json.tycoon_enabled || false
    metadata.tycoon_authentication = json.tycoon_authentication || 'password'
    metadata.planets_metadata = _.map(json.planets_metadata, MetadataPlanet.from_json)
    metadata
