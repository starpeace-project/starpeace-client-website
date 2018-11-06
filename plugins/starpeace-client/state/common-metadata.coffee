
import moment from 'moment'
import Vue from 'vue'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CommonMetadata
  constructor: (@game_state) ->

    @systems_metadata_request = null
    @systems_metadata_as_of = null
    @systems_metadata_by_id = {}
    @system_planets_metadata_by_id = {}

    @planets_metadata_by_system_id_request = {}
    @planets_metadata_by_system_id_as_of = {}
    @planets_metadata_by_system_id = {}
    @planets_metadata_by_id = {}

    @state_counter = 0

  start_systems_metadata_request: () ->
    @systems_metadata_request = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_systems_metadata_request: () ->
    @systems_metadata_request = null
    @state_counter += 1
    @game_state.finish_ajax()

  start_planets_metadata_request: (system_id) ->
    @planets_metadata_by_system_id_request[system_id] = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_planets_metadata_request: (system_id) ->
    @planets_metadata_by_system_id_request[system_id] = null
    @state_counter += 1
    @game_state.finish_ajax()

  is_refreshing_systems_metadata: () -> @systems_metadata_request || false
  is_refreshing_planets_metadata_for_system_id: (system_id) -> system_id?.length && (@planets_metadata_by_system_id_request[system_id] || false)

  has_systems_metadata_any: () -> @systems_metadata_as_of?
  has_systems_metadata_fresh: () -> @systems_metadata_as_of? && TimeUtils.within_minutes(@systems_metadata_as_of, 5)

  has_planets_metadata_any_for_system_id: (system_id) -> system_id? && @planets_metadata_by_system_id_as_of[system_id]?
  has_planets_metadata_fresh_for_system_id: (system_id) -> system_id? && @planets_metadata_by_system_id_as_of[system_id]? && TimeUtils.within_minutes(@planets_metadata_by_system_id_as_of[system_id], 5)

  set_systems_metadata: (systems_metadata) ->
    for system in systems_metadata
      Vue.set(@systems_metadata_by_id, system.id, system)
      Vue.set(@system_planets_metadata_by_id, planet_metadata.id, planet_metadata) for planet_metadata in system.planets_metadata
    @systems_metadata_as_of = moment()
    @state_counter += 1

  set_planets_metadata_for_system: (planets_metadata) ->
    for planet in planets_metadata
      Vue.set(@planets_metadata_by_system_id, planet.system_id, {}) unless @planets_metadata_by_system_id[planet.system_id]?
      Vue.set(@planets_metadata_by_id, planet.id, planet)
      Vue.set(@planets_metadata_by_system_id[planet.system_id], planet.id, planet)
    @planets_metadata_by_system_id_as_of[system_id] = moment() for system_id in _.uniq(_.map(planets_metadata, (planet) -> planet.system_id))
    @state_counter += 1
