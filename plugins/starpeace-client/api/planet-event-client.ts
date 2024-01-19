import _ from 'lodash';
import { gunzipSync } from 'fflate';
import { io, Socket } from 'socket.io-client';
import { SocketIO as MockIO, SocketIOClient } from 'mock-socket';

import { BASE_HOSTNAME } from '~/plugins/starpeace-client/api/sandbox/sandbox-configuration.coffee'
import type ApiClient from '~/plugins/starpeace-client/api/api-client.js'
import BuildingEvent from '~/plugins/starpeace-client/event/building-event.js';
import type ClientState from '~/plugins/starpeace-client/state/client-state.js';
import VisaEvent from '~/plugins/starpeace-client/event/visa-event';
import GalaxyConfiguration from '~/plugins/starpeace-client/galaxy/galaxy-configuration';
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import InitializePayload from './events/initialize-payload';
import SimulationPayload from './events/simulation-payload';

const SEND_VIEW_UPDATE_DELAY_MS = 1000;

export default class PlanetEventClient {
  api: ApiClient;
  clientState: ClientState;

  disconnecting: boolean;
  planetId: string;

  socketEncoding: string;
  socket: Socket | SocketIOClient;

  updateViewTarget: (() => void) | undefined = undefined;

  constructor (api: ApiClient, clientState: ClientState) {
    this.api = api;
    this.clientState = clientState;

    const galaxyId = this.clientState.identity.galaxy_id ?? undefined;
    const galaxyConfig: GalaxyConfiguration | undefined = galaxyId ? this.clientState.core.galaxy_cache.configurationForGalaxyId(galaxyId) : undefined;
    const galaxy: Galaxy | undefined = galaxyId ? this.clientState.core.galaxy_cache.metadataForGalaxyId(galaxyId) : undefined;
    if (!galaxyConfig?.host || !galaxyConfig?.port || !galaxy) {
      throw new Error("no configuration for galaxy");
    }

    if (!this.clientState.player.planet_id) {
      throw new Error("No planet configured");
    }

    this.disconnecting = false;
    this.planetId = this.clientState.player.planet_id;
    this.clientState.planet.connecting = true;
    this.socketEncoding = galaxy.settings.streamEncoding;

    if (galaxyConfig.host == BASE_HOSTNAME) {
      this.api.mockConfiguration.socketEvents.planet_id = this.clientState.player.planet_id
      this.api.mockConfiguration.socketEvents.visa_id = this.clientState.player.planet_visa_id
      this.socket = MockIO.connect(`ws://${galaxyConfig.host}:${galaxyConfig.port}`);
      this.configure();
    }
    else {
      const protocol = galaxyConfig.protocol === 'https' ? 'wss' : 'ws';
      this.socket = io(`${protocol}://${galaxyConfig.host}:${galaxyConfig.port}`, {
        autoConnect: false,
        transports: ['websocket'], // disable 'polling' as long-poll upgrade depends on sticky sessions,
        query: {
          JWT: this.clientState.options.authentication.galaxyJwt,
          PlanetId: this.clientState.player.planet_id,
          VisaId: this.clientState.player.planet_visa_id
        }
      })
      this.configure();
      this.socket.connect();
    }
  }

  disconnect (): void {
    this.disconnecting = true;
    if (this.clientState.planet.connecting || this.clientState.planet.connected) {
      this.socket.disconnect();
    }
  }

  configure (): void {
    this.socket.on('connect_error', (error) => {
      console.log(`error: ${error}`);
    });

    this.socket.on('connect', () => {
      this.clientState.planet.connecting = false;
      this.clientState.planet.connected = true;
      this.clientState.planet.notify_state_listeners();
    });

    this.socket.on('disconnect', () => {
      if (!this.disconnecting && this.planetId == this.clientState.player.planet_id) {
        this.clientState.planet.connecting = false;
        this.clientState.planet.connected = false;
        this.clientState.planet.notify_state_listeners();
        this.clientState.handle_connection_disconnect();
      }
    });

    this.socket.on('initialize', (rawEvent: any) => {
      let eventJson: any = rawEvent;
      if (this.socketEncoding === 'gzip') {
        eventJson = JSON.parse(Array.from(gunzipSync(new Uint8Array(rawEvent))).map(b => String.fromCharCode(b)).join(''));
      }

      const event = InitializePayload.fromJson(eventJson);
      if (event.view) {
        this.clientState.camera.recenterAt(event.view.x, event.view.y);
      }
      this.clientState.planet.load_state(event.planet.time, event.planet);

      if (event.corporation && this.clientState.player.corporation_id) {
        this.clientState.corporation.update_cashflow(event.corporation.lastMailAt, event.corporation.cash, event.corporation.cashflow);
        this.clientState.corporation.update_cashflow_companies(event.corporation.companies);
        this.clientState.core.corporation_cache.update_cashflow(this.clientState.player.corporation_id, event.planet.time, event.corporation.cash, event.corporation.cashflow);
      }
    });

    this.socket.on('simulation', (rawEvent: any) => {
      let eventJson: any = rawEvent;
      if (this.socketEncoding === 'gzip') {
        eventJson = JSON.parse(Array.from(gunzipSync(new Uint8Array(rawEvent))).map(b => String.fromCharCode(b)).join(''));
      }

      const event = SimulationPayload.fromJson(eventJson);
      this.clientState.planet.load_state(event.planet.time, event.planet);

      for (const visa of (event.issuedVisas ?? [])) {
        this.clientState.planet.notifyIssuedVisaListener(new VisaEvent(
          event.planet.time,
          visa.tycoonName,
          visa.corporationName
        ));
      }

      for (const buildingEvent of (event.buildingEvents ?? [])) {
        this.clientState.planet.notifyBuildingListeners(new BuildingEvent(
          event.planet.time,
          buildingEvent.type,
          buildingEvent.id,
          buildingEvent.definitionId,
          buildingEvent.townId,
          buildingEvent.tycoonName,
          buildingEvent.companyName,
          buildingEvent.mapX,
          buildingEvent.mapY
        ));
      }

      if (event.selectedBuilding) {
        if (event.selectedBuilding.constructionProgress !== undefined) {
          this.clientState.core.building_cache.loadConstructionProgress(event.selectedBuilding.id, event.selectedBuilding.constructionProgress);
        }
        this.clientState.core.building_cache.loadCashflow(event.selectedBuilding.id, event.selectedBuilding.cashflow);
        this.clientState.has_dirty_metadata = true;
      }

      if (event.corporation && this.clientState.player.corporation_id) {
        this.clientState.corporation.update_cashflow(event.corporation.lastMailAt, event.corporation.cash, event.corporation.cashflow);
        this.clientState.corporation.update_cashflow_companies(event.corporation.companies);
        this.clientState.core.corporation_cache.update_cashflow(this.clientState.player.corporation_id, event.planet.time, event.corporation.cash, event.corporation.cashflow);
      }
    })
  }

  updateView (): void {
    if (!this.updateViewTarget) {
      this.updateViewTarget = _.debounce(() => {
        if (this.socket && this.clientState.planet?.connected) {
          const center = this.clientState.camera.center();
          const center_iso = this.clientState.camera.map_to_iso(center.x, center.y);
          this.socket.emit('view', {
            viewX: center_iso.i,
            viewY: center_iso.j,
            selectedBuildingId: this.clientState.interface.selected_building_id
          });
        }
      }, SEND_VIEW_UPDATE_DELAY_MS, { leading: true, trailing: true });
    }
    this.updateViewTarget();
  }
}
