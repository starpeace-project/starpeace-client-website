
import _ from 'lodash'

import Cache from '~/plugins/starpeace-client/state/core/cache/cache'

import Logger from '~/plugins/starpeace-client/logger'

export default class GalaxyCache extends Cache
  constructor: () ->
    super()

  reset_multiverse: () ->
    @galaxy_configuration_by_id = {}
    @galaxy_metadata_by_id = {}
    @planet_metadata_by_id = {}

  subscribe_configuration_listener: (listener_callback) -> @event_listener.subscribe('galaxy_cache.configuration', listener_callback)
  notify_configuration_listeners: () -> @event_listener.notify_listeners('galaxy_cache.configuration')
  subscribe_metadata_listener: (listener_callback) -> @event_listener.subscribe('galaxy_cache.metadata', listener_callback)
  notify_metadata_listeners: () -> @event_listener.notify_listeners('galaxy_cache.metadata')

  galaxy_configuration: (galaxy_id) -> @galaxy_configuration_by_id[galaxy_id]
  load_galaxy_configuration: (galaxy_id, galaxy_configuration) ->
    @galaxy_configuration_by_id[galaxy_id] = galaxy_configuration
    @notify_configuration_listeners()

  has_galaxy_metadata: (galaxy_id) -> @galaxy_metadata_by_id[galaxy_id]?
  galaxy_metadata: (galaxy_id) -> @galaxy_metadata_by_id[galaxy_id]
  load_galaxy_metadata: (galaxy_id, galaxy_metadata) ->
    @galaxy_metadata_by_id[galaxy_id] = galaxy_metadata
    @planet_metadata_by_id[planet.id] = planet for planet in (galaxy_metadata?.planets || [])
    @notify_metadata_listeners()

  planet_metadata_for_id: (planet_id) -> @planet_metadata_by_id[planet_id]

  change_galaxy_id: (old_galaxy_id, new_galaxy_id) ->
    if @galaxy_configuration_by_id[old_galaxy_id]?
      @galaxy_configuration_by_id[old_galaxy_id].id = new_galaxy_id
      @galaxy_configuration_by_id[new_galaxy_id] = @galaxy_configuration_by_id[old_galaxy_id]
      delete @galaxy_configuration_by_id[old_galaxy_id]
      @notify_configuration_listeners()
    if @galaxy_metadata_by_id[old_galaxy_id]?
      @galaxy_metadata_by_id[new_galaxy_id] = @galaxy_metadata_by_id[old_galaxy_id]
      delete @galaxy_metadata_by_id[old_galaxy_id]
      @notify_metadata_listeners()

  remove_galaxy: (galaxy_id) ->
    delete @galaxy_configuration_by_id[galaxy_id]
    delete @galaxy_metadata_by_id[galaxy_id]
    @notify_configuration_listeners()
    @notify_metadata_listeners()
