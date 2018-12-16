
import _ from 'lodash'
import moment from 'moment'

import MetadataPlanet from '~/plugins/starpeace-client/planet/metadata-planet.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class MetadataSystem
  constructor: (@id) ->
    @as_of = new Date()

  @from_json: (json) ->
    metadata = new MetadataSystem(json.id)
    metadata.name = json.name
    metadata.enabled = json.enabled
    metadata.population = json.population
    metadata.online_count = json.online_count
    metadata.planets_metadata = _.map(json.planets_metadata, (planet_json) -> MetadataPlanet.from_json(json.id, planet_json))
    metadata
