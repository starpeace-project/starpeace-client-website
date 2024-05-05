
import _ from 'lodash'

import Cache from '~/plugins/starpeace-client/state/core/cache/cache'

import Logger from '~/plugins/starpeace-client/logger'
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import Planet from '~/plugins/starpeace-client/planet/planet';

export default class GalaxyCache extends Cache {
  galaxyConfigurationById: Record<string, any> = {};
  galaxyMetadataById: Record<string, Galaxy> = {};
  planetMetadataById: Record<string, Planet> = {};

  constructor () {
    super()
  }

  reset_multiverse (): void {
    this.galaxyConfigurationById = {};
    this.galaxyMetadataById = {};
    this.planetMetadataById = {};
  }

  subscribe_configuration_listener (listener_callback) {
    this.event_listener.subscribe('galaxy_cache.configuration', listener_callback);
  }
  notify_configuration_listeners () {
    this.event_listener.notify_listeners('galaxy_cache.configuration');
  }
  subscribe_metadata_listener (listener_callback) {
    this.event_listener.subscribe('galaxy_cache.metadata', listener_callback);
  }
  notify_metadata_listeners () {
    this.event_listener.notify_listeners('galaxy_cache.metadata');
  }

  configurationForGalaxyId (galaxyId: string): GalaxyConfiguration {
    return this.galaxyConfigurationById[galaxyId];
  }
  loadGalaxyConfiguration (galaxyId: string, configuration: any): void {
    this.galaxyConfigurationById[galaxyId] = configuration;
    this.notify_configuration_listeners();
  }

  metadataForGalaxyId (galaxyId: string): Galaxy | undefined {
    return this.galaxyMetadataById[galaxyId];
  }
  loadGalaxyMetadata (galaxyId: string, galaxy: Galaxy): void {
    this.galaxyMetadataById[galaxyId] = galaxy;
    for (const planet of (galaxy.planets ?? [])) {
      this.planetMetadataById[planet.id] = planet;
    }
    this.notify_metadata_listeners()
  }

  planet_metadata_for_id (planetId: string): Planet | undefined {
    return this.planetMetadataById[planetId];
  }

  change_galaxy_id (fromGalaxyId: string, targetGalaxyId: string): void {
    if (this.galaxyConfigurationById[fromGalaxyId]) {
      this.galaxyConfigurationById[targetGalaxyId] = this.galaxyConfigurationById[fromGalaxyId];
      this.galaxyConfigurationById[targetGalaxyId].id = targetGalaxyId;
      delete this.galaxyConfigurationById[fromGalaxyId];
      this.notify_configuration_listeners();
    }
    if (this.galaxyMetadataById[fromGalaxyId]) {
      this.galaxyMetadataById[targetGalaxyId] = this.galaxyMetadataById[fromGalaxyId];
      delete this.galaxyMetadataById[fromGalaxyId];
      this.notify_metadata_listeners();
    }
  }

  removeGalaxy (galaxyId: string): void {
    delete this.galaxyConfigurationById[galaxyId];
    delete this.galaxyMetadataById[galaxyId];
    this.notify_configuration_listeners();
    this.notify_metadata_listeners();
  }
}
