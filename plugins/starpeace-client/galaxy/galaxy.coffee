
import _ from 'lodash'
import moment from 'moment'

import Planet from '~/plugins/starpeace-client/planet/planet.coffee'
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class Galaxy
  constructor: (@id) ->
    @as_of = new Date()

    @planets = []

  Object.defineProperties @prototype,
    planet_count:
      get: -> @planets.length
    online_count:
      get: -> _.sumBy(@planets, 'online_count')

  @from_json: (json) ->
    metadata = new Galaxy(json.id)
    metadata.name = json.name
    metadata.visitor_enabled = json.visitorEnabled || false
    metadata.tycoon_enabled = json.tycoonEnabled || false
    metadata.tycoon_creation_enabled = json.tycoonCreationEnabled || false
    metadata.tycoon_authentication = json.tycoonAuthentication || 'password'
    metadata.tycoon = if json.tycoon? then Tycoon.from_json(json.tycoon) else null
    metadata.planets = _.map(json.planets, Planet.from_json)
    metadata
