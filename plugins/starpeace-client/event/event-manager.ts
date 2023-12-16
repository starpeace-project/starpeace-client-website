import _ from 'lodash';

import AssetManager from '~/plugins/starpeace-client/asset/asset-manager.coffee';
import TranslationManager from '~/plugins/starpeace-client/language/translation-manager.js';

import type AjaxState from '~/plugins/starpeace-client/state/ajax-state.js'
import type ClientState from '~/plugins/starpeace-client/state/client-state.js';
import type Options from '~/plugins/starpeace-client/state/options.js';
import VisaEvent, { VisaNewsEvent } from './visa-event';

const EVENT_CHANGE_SPEED = 15000;

export default class EventManager {
  assetManager: AssetManager;
  translationManager: TranslationManager;

  ajaxState: AjaxState;
  clientState: ClientState;

  updateLoop: any | undefined = undefined;

  constructor (assetManager: AssetManager, translationManager: TranslationManager, options: Options, ajaxState: AjaxState, clientState: ClientState) {
    this.assetManager = assetManager;
    this.translationManager = translationManager;
    this.ajaxState = ajaxState;
    this.clientState = clientState;

    options.subscribe_options_listener(async () => {
      await this.queue_asset_load();
      await this.assetManager.load_queued();
      this.updateMessage();
    });

    this.clientState.planet.subscribeIssuedVisaListener((event: any) => this.handleIssuedVisa(event));
  }

  initialize (): void {
    if (!!this.updateLoop) {
      clearTimeout(this.updateLoop);
    }

    this.updateMessage();
    this.updateLoop = setInterval(() => {
      if (this.clientState.workflow_status == 'ready') {
        this.updateMessage();
      }
    }, EVENT_CHANGE_SPEED);
  }

  async queue_asset_load (): Promise<void> {
    const language = this.clientState.options.language()
    if (this.clientState.core.news_library.has_metadata(language)) {
      return;
    }

    this.ajaxState.locked('assets.static_news', language, async () => {
      await new Promise<void>((resolve, reject) => {
        const newsKey = `news.static.${language.toLowerCase()}`;
        this.assetManager.queue(newsKey, `./${newsKey}.json`, (resource: any) => {
          if (resource?.error) {
            reject(resource.error);
          }
          else {
            // FIXME: TODO: convert json to object
            this.clientState.core.news_library.load_static_news(language, resource);
            resolve();
          }
        });
      });
    });
  }

  determineVisaMessage (event: VisaNewsEvent): string {
    const textKey = event.corporationName ? 'misc.event.visa.issued.with_corporation' : 'misc.event.visa.issued';
    const textTemplate = _.template(this.translationManager.text(textKey));
    return textTemplate({
      tycoonName: event.tycoonName ?? this.translationManager.text('identity.visitor'),
      corporationName: event.corporationName,
      planetName: event.planetName
    });
  }

  handleIssuedVisa (event: VisaEvent): void {
    const newsEvent = VisaNewsEvent.from(event, this.clientState.current_planet_metadata()?.name);
    this.clientState.add_system_message(this.determineVisaMessage(newsEvent));
    this.clientState.interface.queueVisaEvent(newsEvent);
  }

  updateMessage (): void {
    const nextVisaEvent = this.clientState.interface.tickerVisaEvents.shift();
    if (nextVisaEvent) {
      this.clientState.interface.updateEventTicker(`${nextVisaEvent.planetTime.toFormat('MMM d, yyyy')} - ${this.determineVisaMessage(nextVisaEvent)}`);
      return;
    }

    const nextBuildingEvent = this.clientState.interface.tickerBuildingEvents.shift();
    if (nextBuildingEvent) {
      nextBuildingEvent.count += this.clientState.interface.mergeEvents(nextBuildingEvent);

      const buildingMetadata = this.clientState.core.building_library.definition_for_id(nextBuildingEvent.definitionId);
      const messageTemplate = _.template(this.translationManager.text('misc.event.ticker.construction'));
      const message = messageTemplate({
        planetTime: nextBuildingEvent.planetTime.toFormat('MMM d, yyyy'),
        tycoonName: nextBuildingEvent.tycoonName,
        companyName: nextBuildingEvent.companyName,
        buildingDescription: `${nextBuildingEvent.count} ${this.translationManager.text(buildingMetadata?.name) ?? nextBuildingEvent.definitionId}`,
        townName: this.clientState.planet.town_for_id(nextBuildingEvent.townId)?.name ?? nextBuildingEvent.townId
      });

      this.clientState.interface.updateEventTickerWithTarget(message, nextBuildingEvent.buildingId, nextBuildingEvent.mapX, nextBuildingEvent.mapY);
      return;
    }

    const language = this.clientState.options.language();
    if (!this.clientState.core.news_library.has_metadata(language)) {
      return;
    }

    const static_news = this.clientState.core.news_library.static_news[language];
    if (this.clientState.interface.static_news_index < 0) {
      this.clientState.interface.static_news_index = Math.floor(Math.random() * static_news.length);
    }
    this.clientState.interface.updateEventTicker(static_news[this.clientState.interface.static_news_index]);

    this.clientState.interface.static_news_index += 1;
    if (this.clientState.interface.static_news_index >= static_news.length) {
      this.clientState.interface.static_news_index = 0;
    }
  }
}
