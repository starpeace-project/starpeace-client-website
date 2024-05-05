import _ from 'lodash';

import { AntennaDefinition, BankDefinition, FactoryDefinition, HeadquartersDefinition, MausoleumDefinition, MediaStationDefinition, OfficeDefinition, ParkDefinition, ResidenceDefinition, ResourceType, ServiceDefinition, StorageDefinition, StoreDefinition, Translation } from '@starpeace/starpeace-assets-types';

import Building from '~/plugins/starpeace-client/building/building.js';
import ClientState from '~/plugins/starpeace-client/state/client-state.js';
import AjaxState from '~/plugins/starpeace-client/state/ajax-state.js';

import Utils from '~/plugins/starpeace-client/utils/utils.js';

import DURATION from '~/plugins/starpeace-client/language/language-duration.json';
import IDENTITY from '~/plugins/starpeace-client/language/language-identity.json';
import MISC from '~/plugins/starpeace-client/language/language-misc.json';
import OVERLAY from '~/plugins/starpeace-client/language/language-overlay.json';

import TOOLBAR_INSPECT from '~/plugins/starpeace-client/language/language-toolbar-inspect.json';
import TOOLBAR_RIBBON from '~/plugins/starpeace-client/language/language-toolbar-ribbon.json';

import UI_MENU_BOOKMARKS from '~/plugins/starpeace-client/language/language-ui-menu-bookmarks.json';
import UI_MENU_CHAT from '~/plugins/starpeace-client/language/language-ui-menu-chat.json';
import UI_MENU_COMPANY from '~/plugins/starpeace-client/language/language-ui-menu-company.json';
import UI_MENU_CONSTUCTION from '~/plugins/starpeace-client/language/language-ui-menu-construction.json';
import UI_MENU_CORPORATION from '~/plugins/starpeace-client/language/language-ui-menu-corporation.json';
import UI_MENU_GALAXY from '~/plugins/starpeace-client/language/language-ui-menu-galaxy.json';
import UI_MENU_HELP from '~/plugins/starpeace-client/language/language-ui-menu-help.json';
import UI_MENU_MAIL from '~/plugins/starpeace-client/language/language-ui-menu-mail.json';
import UI_MENU_OPTIONS from '~/plugins/starpeace-client/language/language-ui-menu-options.json';
import UI_MENU_POLITICS from '~/plugins/starpeace-client/language/language-ui-menu-politics.json';
import UI_MENU_RANKINGS from '~/plugins/starpeace-client/language/language-ui-menu-rankings.json';
import UI_MENU_RELEASE_NOTES from '~/plugins/starpeace-client/language/language-ui-menu-release-notes.json';
import UI_MENU_RESEARCH from '~/plugins/starpeace-client/language/language-ui-menu-research.json';
import UI_MENU_TOWN_SEARCH from '~/plugins/starpeace-client/language/language-ui-menu-town-search.json';
import UI_MENU_TYCOON_DETAILS from '~/plugins/starpeace-client/language/language-ui-menu-tycoon-details.json';
import UI_MENU_TYCOON_SEARCH from '~/plugins/starpeace-client/language/language-ui-menu-tycoon-search.json';

import UI_PAGE_LAYOUT from '~/plugins/starpeace-client/language/language-ui-page-layout.json';

import UI_WORKFLOW_LOADING from '~/plugins/starpeace-client/language/language-ui-workflow-loading.json';
import UI_WORKFLOW_UNIVERSE from '~/plugins/starpeace-client/language/language-ui-workflow-universe.json';


const LANGUAGE_STRINGS = [
  DURATION,
  IDENTITY,
  MISC,
  OVERLAY,
  TOOLBAR_INSPECT,
  TOOLBAR_RIBBON,
  UI_MENU_BOOKMARKS,
  UI_MENU_CHAT,
  UI_MENU_COMPANY,
  UI_MENU_CONSTUCTION,
  UI_MENU_CORPORATION,
  UI_MENU_GALAXY,
  UI_MENU_HELP,
  UI_MENU_MAIL,
  UI_MENU_OPTIONS,
  UI_MENU_POLITICS,
  UI_MENU_RANKINGS,
  UI_MENU_RELEASE_NOTES,
  UI_MENU_RESEARCH,
  UI_MENU_TOWN_SEARCH,
  UI_MENU_TYCOON_DETAILS,
  UI_MENU_TYCOON_SEARCH,
  UI_PAGE_LAYOUT,
  UI_WORKFLOW_LOADING,
  UI_WORKFLOW_UNIVERSE
]


export default class TranslationManager {
  asset_manager: any;
  ajax_state: AjaxState;
  options: any;
  client_state: ClientState;

  translations_by_language_code: Record<string, Record<string, string>> = {};

  constructor (asset_manager: any, ajax_state: any, options: any, client_state: any) {
    this.asset_manager = asset_manager;
    this.ajax_state = ajax_state;
    this.options = options;
    this.client_state = client_state;

    for (const language_values of LANGUAGE_STRINGS) {
      for (const [text_key, languages] of Object.entries(language_values)) {
        for (const [language_code, value] of Object.entries(languages)) {
          if (!this.translations_by_language_code[language_code]) {
            this.translations_by_language_code[language_code] = {};
          }
          this.translations_by_language_code[language_code][text_key] = value
        }
      }
    }
  }

  text (key: Translation | string | undefined): string | undefined {
    if (!key) {
      return undefined;
    }
    else if (key instanceof Translation) {
      return key.forCode(this.options.language()) ?? key.forCode('EN') ?? '';
    }
    else {
      return this.translations_by_language_code[this.options.language()]?.[key] ?? this.translations_by_language_code['EN']?.[key] ?? key;
    }
  }

  resource_details (resourceId: string, maxVelocity: number): any {
    const type: ResourceType | undefined = this.client_state.core.planet_library.resource_type_for_id(resourceId);
    const unit = type ? this.client_state.core.planet_library.resource_unit_for_id(type.unitId) : undefined;
    const amount = maxVelocity * 24;
    return {
      type: type,
      unit: unit,
      amount: amount < 1 ? amount * 7 : amount,
      duration: amount < 1 ? 'duration.week' : 'duration.day'
    }
  }

  label_for_building (building: Building): string {
    const definition = building ? this.client_state.core.building_library.simulation_definition_for_id(building.definition_id) : undefined;
    if (definition?.type == 'TOWNHALL') {
      const town = building.townId ? this.client_state.planet.town_for_id(building.townId) : undefined;
      if (town) {
        return `${this.text('misc.selected.building.townhall')}\n${town.name}\n${town.population} ${this.text('misc.selected.building.townhall.population')}`;
      }
    }
    else if (definition?.type == 'PORTAL') {
      const town = building.townId ? this.client_state.planet.town_for_id(building.townId) : undefined;
      if (town) {
        return `${this.text('misc.selected.building.portal')}\n${town.name}`;
      }
    }
    else if (definition?.type == 'TRADECENTER') {
      const town = building.townId ? this.client_state.planet.town_for_id(building.townId) : undefined;
      const seal = town?.seal_id ? this.client_state.core.planet_library.seal_for_id(town.seal_id) : undefined;
      if (seal) {
        return `${this.text('misc.selected.building.tradecenter')}\n${seal.nameShort}`;
      }
    }
    else {
      const building_name = building?.name;
      const company = building ? this.client_state.core.company_cache.metadataForId(building.company_id) : undefined;
      const company_name = company?.name;

      const parts = [];
      if (building_name && company_name) {
        parts.push(building_name);
        parts.push(company_name);

        if (!building.constructed || building.upgrading) {
          const progress: number | undefined = this.client_state.core.building_cache.constructionProgressForBuildingId(building.id);
          if (progress === undefined) {
            parts.push(this.text('misc.selected.building.scanning'));
          }
          else {
            parts.push(`${Math.round(progress * 100)}% ${this.text('misc.selected.building.completed')}`);
          }
        }

        const cashflow: number | undefined = this.client_state.core.building_cache.cashflowForBuildingId(building.id);
        if (cashflow !== undefined) {
          parts.push(`($${Math.round(cashflow).toLocaleString()}/h)`);
        }
        return parts.join('\n');
      }
    }
    return this.text('misc.selected.building.scanning') ?? '...';
  }


  description_for_building (building_definition: any): string {
    const textSeparator: string = this.text('misc.and') ?? '&';

    const definition = this.client_state.core.building_library.simulation_definition_for_id(building_definition.id);

    if (definition instanceof BankDefinition) {
      return this.text('ui.menu.construction.description.bank.label') ?? '';
    }
    else if (definition instanceof MausoleumDefinition) {
      return this.text('ui.menu.construction.description.mausoleum.label') ?? '';
    }
    else if (definition instanceof FactoryDefinition) {
      const template_description = _.template(this.text('ui.menu.construction.description.industry.label'))
      const template_output = _.template(this.text('ui.menu.construction.description.industry.output.label'))
      const template_input = _.template(this.text('ui.menu.construction.description.industry.input.label'))

      const description_parts = []
      const output_label_parts = _.map(definition.outputs, (output) => {
        const resurce = this.resource_details(output.resourceId, output.maxVelocity);
        return template_output({amount: resurce.amount, resource: this.text(resurce.type?.labelPlural), unit: this.text(resurce.unit?.labelPlural), duration: this.text(resurce.duration)});
      });

      if (output_label_parts.length) {
        description_parts.push(template_description({output: Utils.join_with_oxford_comma(output_label_parts, textSeparator)}));
      }

      const inputs = definition.inputs.map((input) => this.text(this.client_state.core.planet_library.resource_type_for_id(input.resourceId)?.labelPlural) ?? input.resourceId);
      if (inputs.length) {
        description_parts.push(template_input({input: Utils.join_with_oxford_comma(inputs, textSeparator)}));
      }

      return description_parts.join(' ');
    }
    else if (definition instanceof HeadquartersDefinition) {
      return this.text('ui.menu.construction.description.headquarters.label') ?? '';
    }
    else if (definition instanceof AntennaDefinition) {
      const template_antenna = _.template(this.text('ui.menu.construction.description.media.antenna.label'));
      return template_antenna({ range: (definition.range * 20) });
    }
    else if (definition instanceof MediaStationDefinition) {
      return this.text('ui.menu.construction.description.media.station.label') ?? '';
    }
    else if (definition instanceof OfficeDefinition) {
      const template_efficiency = _.template(this.text('ui.menu.construction.description.real_estate.efficiency.label'));
      const template_offices = _.template(this.text('ui.menu.construction.description.offices.rent.label'));

      const params_efficiency = { efficiency: Math.round(definition.efficiency * 100) };
      const params_offices = { amount: definition.capacity };

      return `${template_offices(params_offices)}. ${template_efficiency(params_efficiency)}`;
    }
    else if (definition instanceof ParkDefinition) {
      // TODO: no existing descriptions to re-use
      return '';
    }
    else if (definition instanceof ResidenceDefinition) {
      const residential_type = this.client_state.core.planet_library.type_for_id(building_definition.industryTypeId);
      const template_efficiency = _.template(this.text('ui.menu.construction.description.real_estate.efficiency.label'))
      const template_inhabitants = _.template(this.text('ui.menu.construction.description.residential.inhabitants.label'))
      const template_resistences = _.template(this.text('ui.menu.construction.description.residential.resistences.label'))

      const params_efficiency = { efficiency: Math.round(definition.efficiency * 100) }
      const params_inhabitants = { amount: definition.capacity }
      const params_resistences = { crime: Math.round(definition.crimeResistence * 100), pollution: Math.round(definition.pollutionResistence * 100) }

      return `${this.text(residential_type.label)}. ${template_inhabitants(params_inhabitants)}. ${template_resistences(params_resistences)}. ${template_efficiency(params_efficiency)}`;
    }
    else if (definition instanceof ServiceDefinition) {
      // TODO: no existing descriptions to re-use
      return '';
    }
    else if (definition instanceof StorageDefinition) {
      const template_description = _.template(this.text('ui.menu.construction.description.warehouse.label'));
      const template_output = _.template(this.text('ui.menu.construction.description.warehouse.output.label'));

      const storage_parts = _.map(definition.storage, (storage) => {
        const type = this.client_state.core.planet_library.resource_type_for_id(storage.resourceId);
        const unit = type ? this.client_state.core.planet_library.resource_unit_for_id(type.unitId) : undefined;
        return template_output({amount: storage.max, resource: this.text(type?.labelPlural), unit: this.text(unit?.labelPlural)})
      });

      return template_description({storage: Utils.join_with_oxford_comma(storage_parts, textSeparator)})
    }
    else if (definition instanceof StoreDefinition) {
      const template_sells = _.template(this.text('ui.menu.construction.description.store.sells.label'));
      const template_provides = _.template(this.text('ui.menu.construction.description.store.provides.label'));
      const template_resource = _.template(this.text('ui.menu.construction.description.store.resource.label'));

      const sell_parts = [];
      const buy_parts = [];
      const provide_parts = [];

      for (const product of definition.products) {
        const inputs = product.inputs.map((i) => _.pick(i, 'resourceId', 'maxVelocity'));
        const outputs = product.outputs.map((o) => _.pick(o, 'resourceId', 'maxVelocity'));

        if (_.isEqual(inputs, outputs)) {
          for (const output of outputs) {
            const resource = this.resource_details(output.resourceId, output.maxVelocity);
            sell_parts.push(template_resource({amount: resource.amount, resource: this.text(resource.type?.labelPlural), unit: this.text(resource.unit?.labelPlural), duration: this.text(resource.duration)}));
          }
        }
        else {
          for (const input of inputs) {
            const resource = this.resource_details(input.resourceId, input.maxVelocity);
            buy_parts.push(template_resource({amount: resource.amount, resource: this.text(resource.type?.labelPlural), unit: this.text(resource.unit?.labelPlural), duration: this.text(resource.duration)}));
          }
          for (const output of outputs) {
            const resource = this.resource_details(output.resourceId, output.maxVelocity);
            provide_parts.push(template_resource({amount: resource.amount, resource: this.text(resource.type?.labelPlural), unit: this.text(resource.unit?.labelPlural), duration: this.text(resource.duration)}));
          }
        }
      }

      const descriptions = [];
      if (sell_parts.length) {
        descriptions.push(template_sells({sells: Utils.join_with_oxford_comma(sell_parts, textSeparator)}));
      }
      if (buy_parts.length && provide_parts.length) {
        descriptions.push(template_provides({buys: Utils.join_with_oxford_comma(buy_parts, textSeparator), provides: Utils.join_with_oxford_comma(provide_parts, textSeparator)}));
      }
      return descriptions.join(' ');
    }

    return '';
  }
}
